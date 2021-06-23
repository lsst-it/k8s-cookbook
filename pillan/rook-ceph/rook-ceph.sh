#!/bin/bash

set -ex

helm repo add rook-release https://charts.rook.io/release
helm repo update
kubectl create namespace rook-ceph --dry-run -o yaml | kubectl apply -f -

helm install rook-ceph rook-release/rook-ceph \
  --namespace rook-ceph \
  --version v1.6.5 \
  -f ./values.yaml

# toolbox needs affinity & tolerations
# https://raw.githubusercontent.com/rook/rook/v1.6.5/cluster/examples/kubernetes/ceph/toolbox.yaml
kubectl apply -f toolbox.yaml

kubectl apply -f cephcluster.yaml
kbuectl apply -f ceph-dashboard-ingress.yaml
kubectl apply -f cephblockpool.yaml
kubectl apply -f ceph-storageclass.yaml

# dashboard setup is buggy; flopping it disable/enable seems to fix it:
kubectl -n rook-ceph patch cephcluster.ceph.rook.io/rook-ceph --type merge -p '{"spec":{"dashboard": {"enabled": false}}}'
kubectl -n rook-ceph patch cephcluster.ceph.rook.io/rook-ceph --type merge -p '{"spec":{"dashboard": {"enabled": true}}}'

# dashboard creds:
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo

# vim: tabstop=2 shiftwidth=2 expandtab
