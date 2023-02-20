#!/bin/bash

set -ex

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install \
  kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --create-namespace --namespace prometheus \
  --version v44.2.1 \
  --atomic
