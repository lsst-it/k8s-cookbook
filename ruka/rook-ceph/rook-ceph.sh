#!/bin/bash

set -ex

VERSION='1.9.9'

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

# cephfs w/ nfs
kubectl apply -f nfs/cephfs-jhome.yaml
kubectl apply -f nfs/cephfs-lsstdata.yaml
kubectl apply -f nfs/cephfs-project.yaml
kubectl apply -f nfs/cephfs-scratch.yaml

# lfa/s3
kubectl apply -f s3/object_store.yaml
kubectl apply -f s3/ingress.yaml

# no spaces after `,`s is allowed
kubectl -n rook-ceph exec -it "$(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}')" -- \
ceph dashboard set-ganesha-clusters-rados-pool-namespace \
scratch:nfs-ganesha/scratch,\
jhome:nfs-ganesha/jhome,\
lsstdata:nfs-ganesha/lsstdata,\
project:nfs-ganesha/project

# XXX post rook 1.7.x we are suppose to unset the manual dashboard... but it doesn't work
#kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- \
#  ceph dashboard set-ganesha-clusters-rados-pool-namespace ""

# XXX at least rook 1.7.[78] do not set the application type on the nfs-ganesha pool. This causes a ceph health warning.
kubectl -n rook-ceph exec -it "$(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}')" -- \
  ceph osd pool application enable nfs-ganesha nfs

# vim: tabstop=2 shiftwidth=2 expandtab
