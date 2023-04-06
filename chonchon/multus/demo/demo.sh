#!/bin/bash

set -ex

NS=(
  multus-demo-lhn
)

kubectl apply -f multus-demo.yaml

for n in "${NS[@]}"; do
  echo "### NS: ${n} ###"
  kubectl wait --for=condition=ready pod -n "$n" -l app=multus-demo
  kubectl -n "$n" exec -ti multus-demo -c iperf -- ip route
  echo
done

kubectl delete -f multus-demo.yaml
