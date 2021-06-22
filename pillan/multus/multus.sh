#!/bin/bash

set -ex

( set -ex
  git clone https://github.com/intel/multus-cni -b v3.7.1
  cd multus-cni
  kubectl apply -f images/multus-daemonset.yml
)

NADS=(
  multus-nad-auxtel-dds.yaml
  multus-nad-comcam-dds.yaml
  multus-nad-misc-dds.yaml
)

for n in "${NADS[@]}"; do
  kubectl apply -f "${n}"
done


# vim: tabstop=2 shiftwidth=2 expandtab
