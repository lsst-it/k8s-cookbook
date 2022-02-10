#!/bin/bash

set -ex

helm repo add rook-release https://charts.rook.io/release
helm repo update

helm upgrade --install \
  rook-ceph rook-release/rook-ceph \
  --create-namespace --namespace rook-ceph \
  --version v1.8.4 \
  -f ./rook-ceph-values.yaml

helm repo add rook-master https://charts.rook.io/master
helm repo update

helm upgrade --install \
  rook-ceph-cluster rook-master/rook-ceph-cluster \
  --create-namespace --namespace rook-ceph \
  --set operatorNamespace=rook-ceph \
  -f ./rook-ceph-cluster-values.yaml

kubectl apply -f cephblockpool.yaml
kubectl apply -f ceph-storageclass.yaml
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
# vim: tabstop=2 shiftwidth=2 expandtab
