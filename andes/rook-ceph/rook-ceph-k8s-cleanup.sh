#!/bin/bash

set -ex

#kubectl -n rook-ceph patch crd cephclusters.ceph.rook.io --type merge -p '{"metadata":{"finalizers": [null]}}'

kubectl delete -f ceph-storageclass.yaml
kubectl delete -f cephblockpool.yaml
kubectl delete -f cephcluster.yaml

( set -ex
  cd rook/cluster/examples/kubernetes/ceph/
  kubectl delete -f toolbox.yaml
  kubectl delete -f operator.yaml
  kubectl delete -f common.yaml
  kubectl delete ns rook-ceph
)

# vim: tabstop=2 shiftwidth=2 expandtab
