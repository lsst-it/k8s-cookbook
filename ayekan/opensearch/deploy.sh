#!/usr/bin/env bash

NAMESPACE="opensearch"
VERSION="2.5.1"

set -ex

helm repo add opensearch-operator https://opensearch-project.github.io/opensearch-k8s-operator
helm repo update

kubectl apply -f ./namespace.yaml

helm upgrade --install opensearch-operator opensearch-operator/opensearch-operator \
     --create-namespace --namespace "${NAMESPACE=}" \
     --atomic --timeout 15m0s \
     --version "${VERSION=}" \
     -f ./values.yaml

kubectl --namespace "${NAMESPACE=}" apply -f ./clusters
