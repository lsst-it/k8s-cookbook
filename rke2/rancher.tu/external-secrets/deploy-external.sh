#!/bin/bash

set -xe

helm upgrade --install external-secrets external-secrets \
  --namespace external-secrets \
  --create-namespace \
  --repo https://charts.external-secrets.io \
  --version 0.15.0 \
  --wait --timeout 300s \
  --atomic

kubectl apply -f clustersecretstore-onepassword.yaml
