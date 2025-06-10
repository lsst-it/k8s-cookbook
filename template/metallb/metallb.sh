#!/bin/bash
set -xe

helm upgrade --install metallb metallb/metallb \
  --repo https://metallb.github.io/metallb \
  --version 0.14.9 \
  --namespace metallb-system --create-namespace \
  --atomic \
  --timeout 600s --wait

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=metallb -n metallb-system --timeout=180s

kubectl apply -f ipaddresspool-ingress.yaml
