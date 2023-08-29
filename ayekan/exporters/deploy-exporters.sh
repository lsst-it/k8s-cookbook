#! /usr/bin/env bash

set -ex

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create ns monitoring --dry-run=client -oyaml | kubectl apply -f -
kubectl --namespace monitoring apply -f snmp-configmap.yaml
helm upgrade --install snmp-exporter prometheus-community/prometheus-snmp-exporter \
     --create-namespace --namespace monitoring \
     --atomic --timeout 15m0s \
     -f ./snmp-exporter.yaml

helm upgrade --install blackbox-exporter prometheus-community/prometheus-blackbox-exporter \
     --create-namespace --namespace monitoring \
     --atomic --timeout 15m0s \
     -f ./blackbox-exporter.yaml
