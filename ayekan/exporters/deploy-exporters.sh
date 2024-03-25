#! /usr/bin/env bash

set -euxo pipefail

NAMESPACE="monitoring"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kminion https://raw.githubusercontent.com/cloudhut/kminion/master/charts/archives
helm repo update

kubectl create ns ${NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

# SNMP configuration
kubectl --namespace ${NAMESPACE} apply -f snmp-exporter/configmap.yaml
kubectl --namespace ${NAMESPACE} apply -f snmp-exporter/xups-configmap.yaml
kubectl --namespace ${NAMESPACE} apply -f snmp-exporter/schneider-configmap.yaml
kubectl --namespace ${NAMESPACE} apply -f snmp-exporter/externalsecret.yaml
helm upgrade --install snmp-exporter prometheus-community/prometheus-snmp-exporter \
     --create-namespace --namespace ${NAMESPACE=} \
     --atomic --timeout 15m \
     --version "1.8.1" \
     -f ./snmp-exporter/helm-values.yaml

# Blackbox configuration
helm upgrade --install blackbox-exporter prometheus-community/prometheus-blackbox-exporter \
     --create-namespace --namespace ${NAMESPACE=} \
     --atomic --timeout 15m \
     --version "8.4.0" \
     -f ./blackbox-exporter/helm-values.yaml

# puppetdb exporter
kubectl --namespace ${NAMESPACE=} apply -f puppetdb-exporter/deployment.yaml
