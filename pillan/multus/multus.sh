#!/bin/bash

set -ex

( set -ex
  git clone https://github.com/intel/multus-cni -b v3.7.1
  cd multus-cni
  kubectl apply -f images/multus-daemonset.yml
)

kubectl apply -f multus-network-attachment-definition.yaml

# vim: tabstop=2 shiftwidth=2 expandtab
