#!/usr/bin/env bash

NAMESPACE="fluent"
VERSION="2.7.0"

set -ex

helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

kubectl apply -f ./namespace.yaml

helm upgrade --install fluent-operator fluent/fluent-operator \
     --create-namespace --namespace "${NAMESPACE=}" \
     --atomic --timeout 10m0s \
     --version "${VERSION=}" \
     -f ./values.yaml

kubectl --namespace "${NAMESPACE=}" apply -f ./configs
