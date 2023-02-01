#!/bin/bash
set -ex
( set -ex
  git clone https://github.com/k8snetworkplumbingwg/multus-cni -b v3.7.1
  cd multus-cni
  kubectl apply -f images/multus-daemonset.yml
)

kubectl apply -f multus-nad-default.yaml
kubectl apply -f multus-nad-lhn.yaml

# vim: tabstop=2 shiftwidth=2 expandtab
