#!/bin/bash
set -xe

helm repo add metallb https://metallb.github.io/metallb

helm upgrade --install metallb metallb/metallb \
  --namespace metallb-system \
  --create-namespace \
  --version 0.14.9 \

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=metallb -n metallb-system --timeout=180s

kubectl apply -f ipaddresspool-ingress.yaml
