#! /usr/bin/env bash

set -ex

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install ayekan-mimir grafana/mimir-distributed \
     --create-namespace --namespace mimir \
     --atomic --timeout 60m0s \
     -f ./mimir.yaml
