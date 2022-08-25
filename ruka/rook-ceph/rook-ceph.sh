#!/bin/bash

set -ex

VERSION='1.9.9'

cephtoolbox() {
  # shellcheck disable=SC2068
  kubectl -n rook-ceph exec -it "$(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}')" -- $@
}

helm repo add rook-release https://charts.rook.io/release
helm repo update

helm upgrade --install \
  rook-ceph rook-release/rook-ceph \
  --create-namespace --namespace rook-ceph \
  --version "v${VERSION}" \
  -f ./rook-ceph-values.yaml

helm upgrade --install \
  rook-ceph-cluster rook-release/rook-ceph-cluster \
  --create-namespace --namespace rook-ceph \
  --set operatorNamespace=rook-ceph \
  --version "v${VERSION}" \
  -f ./rook-ceph-cluster-values.yaml

kubectl apply -f cephblockpool.yaml
kubectl apply -f ceph-storageclass.yaml
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# dashboard creds
while :; do
  kubectl -n rook-ceph get pod -l app=rook-ceph-mgr,ceph_daemon_id=a,rook_cluster=rook-ceph && break
  sleep 3
done
kubectl -n rook-ceph wait --for=condition=ready --timeout=180s pod -l app=rook-ceph-mgr,ceph_daemon_id=a,rook_cluster=rook-ceph

set +x
echo "===================="
echo "dashboard passphrase"
echo "===================="
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
echo "===================="
set -x

# cephfs w/ nfs
kubectl apply -f nfs/cephfs-jhome.yaml
kubectl apply -f nfs/cephfs-lsstdata.yaml
kubectl apply -f nfs/cephfs-project.yaml
kubectl apply -f nfs/cephfs-scratch.yaml

# lfa/s3
kubectl apply -f s3/object_store.yaml
kubectl apply -f s3/ingress.yaml

# enable ceph orchestrator for nfs
# as of 1.9.9, this is needed to enable configuration of nfs exports via both
# the dashboard and the cli
# https://rook.io/docs/rook/v1.9/CRDs/ceph-nfs-crd/?h=nfs#enable-the-ceph-orchestrator-if-necessary
cephtoolbox ceph mgr module enable rook
cephtoolbox ceph mgr module enable nfs
cephtoolbox ceph orch set backend rook

cephtoolbox ceph nfs export rm jhome /jhome
cephtoolbox ceph nfs export create cephfs jhome /jhome jhome
cephtoolbox ceph nfs export rm lsstdata /lsstdata
cephtoolbox ceph nfs export create cephfs lsstdata /lsstdata lsstdata
cephtoolbox ceph nfs export rm project /project
cephtoolbox ceph nfs export create cephfs project /project project
cephtoolbox ceph nfs export rm scratch /scratch
cephtoolbox ceph nfs export create cephfs scratch /scratch scratch

# vim: tabstop=2 shiftwidth=2 expandtab
