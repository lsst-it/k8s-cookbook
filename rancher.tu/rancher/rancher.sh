#!/bin/bash

set -ex

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

helm upgrade --install \
  rancher rancher-stable/rancher \
  --create-namespace --namespace cattle-system \
  --set hostname=rancher.tu.lsst.org \
  --set ingress.tls.source=secret \
  --version v2.6.6 \
  -f ./values.yaml

kubectl -n cattle-system rollout status deploy/rancher
