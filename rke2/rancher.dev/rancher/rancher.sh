#!/bin/bash

set -ex

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

helm upgrade --install \
  rancher rancher-stable/rancher \
  --create-namespace --namespace cattle-system \
  --version v2.11.0 \
  -f ./values.yaml

kubectl -n cattle-system rollout status deploy/rancher
