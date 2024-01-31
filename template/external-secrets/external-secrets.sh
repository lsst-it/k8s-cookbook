#!/bin/bash

set -ex

helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm upgrade --install \
  external-secrets external-secrets/external-secrets \
  --create-namespace --namespace external-secrets \
  --version v0.9.11 \
  --atomic

kubectl apply -f secret-onepassword-token.yaml
kubectl apply -f clustersecretstore-onepassword.yaml
