#!/bin/bash

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install \
  grafana-agent grafana/grafana-agent \
  --create-namespace --namespace grafana-agent \
  --version v0.27.1 \
  --atomic \
  -f values.yaml
