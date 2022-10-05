#!/bin/bash

set -e x

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo update

helm upgrade --install \
  kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --create-namespace --namespace kube-prometheus-stack \
  -f ./values.yaml \
  --atomic

# sanity check
kubectl --namespace kube-prometheus-stack get pods -l "release=kube-prometheus-stack"
