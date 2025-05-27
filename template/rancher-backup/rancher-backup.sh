#!/bin/bash
set -xe

kubectl create namespace cattle-resources-system || true

kubectl apply -f externalsecret-rancher-bkp.yaml

helm upgrade --install rancher-backup-crd rancher-backup-crd \
  --namespace cattle-resources-system \
  --create-namespace \
  --repo https://charts.rancher.io \
  --version 104.0.2+up5.0.2 \
  --wait --timeout 60s \
  --atomic

helm upgrade --install rancher-backup rancher-backup \
  --namespace cattle-resources-system \
  --create-namespace \
  --repo https://charts.rancher.io \
  --version 104.0.2+up5.0.2 \
  --wait --timeout 60s \
  --atomic \
  -f values.yaml
