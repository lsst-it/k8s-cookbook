#!/bin/bash

set -ex

# kubectl -n rook-ceph patch cephclusters.ceph.rook.io rook-ceph --type merge -p '{"metadata":{"finalizers": [null]}}'

kubectl delete -f ceph-storageclass.yaml
kubectl delete -f cephblockpool.yaml

helm delete -n rook-ceph rook-ceph-cluster
helm delete -n rook-ceph rook-ceph

kubectl delete ns rook-ceph

# vim: tabstop=2 shiftwidth=2 expandtab
