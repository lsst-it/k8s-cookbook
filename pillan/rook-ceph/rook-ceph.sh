#!/bin/bash

set -ex

helm repo add rook-release https://charts.rook.io/release
helm repo update

helm upgrade --install \
  rook-ceph rook-release/rook-ceph \
  --create-namespace --namespace rook-ceph \
  --version v1.6.7 \
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

# dashboard setup is buggy; flopping it disable/enable seems to fix it:
kubectl -n rook-ceph patch cephcluster.ceph.rook.io/rook-ceph --type merge -p '{"spec":{"dashboard": {"enabled": false}}}'
kubectl -n rook-ceph patch cephcluster.ceph.rook.io/rook-ceph --type merge -p '{"spec":{"dashboard": {"enabled": true}}}'

# dashboard creds:
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo

# vim: tabstop=2 shiftwidth=2 expandtab
