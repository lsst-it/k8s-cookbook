#! /usr/bin/env bash

set -euxo pipefail

NAMESPACE="monitoring"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kminion https://raw.githubusercontent.com/cloudhut/kminion/master/charts/archives
helm repo update

kubectl create ns ${NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

kubectl apply -f configmap-snmp-config-tmpl.yaml
kubectl apply -f externalsecret-snmp-community.yaml

# SNMP configuration
kubectl --namespace ${NAMESPACE} apply -f snmp-configmap.yaml
helm upgrade --install snmp-exporter prometheus-community/prometheus-snmp-exporter \
     --create-namespace --namespace ${NAMESPACE=} \
     --atomic --timeout 15m \
     --version "1.8.1" \
     -f ./snmp-exporter.yaml

# Blackbox configuration
helm upgrade --install blackbox-exporter prometheus-community/prometheus-blackbox-exporter \
     --create-namespace --namespace ${NAMESPACE=} \
     --atomic --timeout 15m \
     --version "8.4.0" \
     -f ./blackbox-exporter.yaml

# kminion - kafka exporter
kubectl --namespace ${NAMESPACE=} apply -f kminion-deployment.yaml
kubectl --namespace ${NAMESPACE=} apply -f kminion-configmap-secret.yaml
