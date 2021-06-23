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
kubectl apply -f cephblockpool.yaml
kubectl apply -f ceph-storageclass.yaml

# vim: tabstop=2 shiftwidth=2 expandtab
