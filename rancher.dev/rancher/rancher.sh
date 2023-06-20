#!/bin/bash

set -ex

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

helm upgrade --install \
  --atomic \
  rancher rancher-stable/rancher \
  --create-namespace --namespace cattle-system \
  --version v2.7.4 \
  --set global.cattle.psp.enabled=false \
  -f ./values.yaml

kubectl -n cattle-system rollout status deploy/rancher
