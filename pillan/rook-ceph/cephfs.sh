#!/bin/bash

set -ex

kubectl apply -f cephfs-jhome.yaml
kubectl apply -f cephfs-lsstdata.yaml
kubectl apply -f cephfs-project.yaml
kubectl apply -f cephfs-scratch.yaml

# no spaces after `,`s is allowed
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- \
ceph dashboard set-ganesha-clusters-rados-pool-namespace \
scratch:scratch-data0/nfs-ns,\
jhome:jhome-data0/nfs-ns,\
lsstdata:lsstdata-data0/nfs-ns,\
project:project-data0/nfs-ns
