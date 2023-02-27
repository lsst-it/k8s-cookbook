#!/bin/bash

set -ex

PODS=(
  multus-demo-auxtel
  multus-demo-comcam
  multus-demo-misc
)

kubectl apply -f multus-demo.yaml
kubectl wait --for=condition=ready pod -l app=multus-demo

for p in "${PODS[@]}"; do
  echo "### POD: ${p} ###"
  kubectl logs "$p" -c ddsnet4u
  kubectl exec -ti "$p" -c iperf -- ip route
  echo
done

kubectl delete -f multus-demo.yaml
