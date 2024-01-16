#! /usr/bin/env bash

set -euxo pipefail

NAMESPACE="kube-prometheus-stack"

kubectl create configmap prometheus-snmp-csv-network --from-file=snmp-csv-network.json=./target-csv.json --namespace ${NAMESPACE=} -o yaml --dry-run=client | kubectl apply -f -
