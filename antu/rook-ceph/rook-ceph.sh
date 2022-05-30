#!/bin/bash

set -ex

helm repo add rook-release https://charts.rook.io/release
helm repo update

helm upgrade --install \
  rook-ceph rook-release/rook-ceph \
  --create-namespace --namespace rook-ceph \
  --version v1.7.8 \
  -f ./rook-ceph-values.yaml

helm repo add rook-master https://charts.rook.io/master
helm repo update

helm upgrade --install \
  rook-ceph-cluster rook-master/rook-ceph-cluster \
  --create-namespace --namespace rook-ceph \
  --set operatorNamespace=rook-ceph \
  -f ./rook-ceph-cluster-values.yaml

kubectl apply -f ceph-dashboard-ingress.yaml
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
