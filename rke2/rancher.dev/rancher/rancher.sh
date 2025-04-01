#!/bin/bash

set -ex

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

helm upgrade --install \
  rancher rancher-latest/rancher \
  --create-namespace --namespace cattle-system \
  --version v2.11.0 \
  -f ./values.yaml

kubectl -n cattle-system rollout status deploy/rancher
