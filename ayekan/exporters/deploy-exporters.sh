#! /usr/bin/env bash

set -euxo pipefail

NAMESPACE="monitoring"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

if [ -f ./snmp-configmap.yaml ]; then
    rm ./snmp-configmap.yaml
fi

if [ -z ${LSST_SNMP_COMMUNITY+x} ]; then
    echo "Please set the LSST_SNMP_COMMUNITY variable before deploying exporters"
	exit 1
else
    envsubst -i ./snmp-configmap.tmpl -o ./snmp-configmap.yaml
fi

kubectl create ns ${NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -
kubectl --namespace ${NAMESPACE} apply -f snmp-configmap.yaml
helm upgrade --install snmp-exporter prometheus-community/prometheus-snmp-exporter \
     --create-namespace --namespace ${NAMESPACE} \
     --atomic --timeout 15m0s \
     --version "1.8.1" \
     -f ./snmp-exporter.yaml

helm upgrade --install blackbox-exporter prometheus-community/prometheus-blackbox-exporter \
     --create-namespace --namespace ${NAMESPACE} \
     --atomic --timeout 15m0s \
     --version "8.4.0" \
     -f ./blackbox-exporter.yaml
