#! /usr/bin/env bash

set -euxo pipefail

NAMESPACE="monitoring"


kubectl create ns ${NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

# puppetdb exporter
kubectl --namespace ${NAMESPACE=} apply -f puppetdb-exporter/deployment.yaml
