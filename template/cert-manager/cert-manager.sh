#!/bin/bash
set -xe

kubectl create namespace cert-manager || true

kubectl apply -f secret-aws.yaml

helm upgrade --install cert-manager cert-manager \
  --repo https://charts.jetstack.io \
  --version v1.17.1 \
  --namespace cert-manager --create-namespace \
  --set crds.enabled=true \
  --atomic \
  --timeout 600s --wait
