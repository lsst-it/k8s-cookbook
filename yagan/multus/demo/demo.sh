#!/bin/bash

set -ex

kubectl apply -f multus-demo.yaml
kubectl wait --for=condition=ready pod -l app=multus-demo

kubectl logs multus-demo -c ddsnet4u
kubectl exec -ti multus-demo -c iperf -- ip route

kubectl delete -f multus-demo.yaml
