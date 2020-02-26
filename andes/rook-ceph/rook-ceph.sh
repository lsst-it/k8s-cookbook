#!/bin/bash

set -ex

( set -ex
  git clone https://github.com/rook/rook -b release-1.2
  cd rook/cluster/examples/kubernetes/ceph/
  kubectl create -f common.yaml
  kubectl create -f operator.yaml
  kubectl create -f toolbox.yaml
)

kubectl apply -f cephcluster.yaml
kubectl apply -f cephblockpool.yaml
kubectl apply -f ceph-storageclass.yaml

# vim: tabstop=2 shiftwidth=2 expandtab
