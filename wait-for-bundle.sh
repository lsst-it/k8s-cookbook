#!/bin/sh

while true; do
  kubectl -n fleet-local wait --for=condition=ready bundle -l bundle=metallb --timeout=10s
  kubectl get bundle -A
  sleep 5
done
