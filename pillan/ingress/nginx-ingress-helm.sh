#!/bin/bash

set -ex

helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update

kubectl create namespace nginx-ingress

helm install nginx-ingress stable/nginx-ingress \
  --namespace nginx-ingress \
  --set controller.kind=DaemonSet \
  --set defaultBackend.replicaCount=1 \
  --set rbac.create=true
