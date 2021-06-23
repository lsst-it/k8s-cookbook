#!/bin/bash

set -e x


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo update

kubectl create namespace kube-prometheus-stack --dry-run -o yaml | kubectl apply -f -

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace kube-prometheus-stack

# sanity check
kubectl --namespace kube-prometheus-stack get pods -l "release=kube-prometheus-stack"
