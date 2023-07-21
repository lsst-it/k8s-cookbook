#!/bin/bash
set -ex

helm repo add influxdata https://helm.influxdata.com/
helm repo add grafana https://grafana.github.io/helm-charts

helm upgrade --install \
  telegraf influxdata/telegraf \
  --create-namespace --namespace power-monitor \
  --version "v1.8.29" \
  --atomic

helm upgrade --install \
  influxdb influxdata/influxdb \
  --create-namespace --namespace power-monitor \
  --version "v4.12.4" \
  --atomic

helm upgrade --install grafana \
  --version="6.58.3" \
  --namespace power-monitor \
  --create-namespace \
  grafana/grafana \
  --atomic
