#!/bin/bash

set -ex

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

helm upgrade --install \
  --atomic \
  rancher rancher-latest/rancher \
  --create-namespace --namespace cattle-system \
  --version v2.8.5 \
  -f ./values.yaml

kubectl -n cattle-system rollout status deploy/rancher
