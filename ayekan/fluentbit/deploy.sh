#!/usr/bin/env bash

NAMESPACE="monitoring"
VERSION="0.42.0"

set -ex

helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

helm upgrade --install ayekan-fluentbit fluent/fluent-bit \
     --create-namespace --namespace "${NAMESPACE=}" \
     --atomic --timeout 10m0s \
     --version "${VERSION=}" \
     -f ./values.yaml

# kubectl --namespace "${NAMESPACE=}" apply -f ./daemonset-config.yaml
