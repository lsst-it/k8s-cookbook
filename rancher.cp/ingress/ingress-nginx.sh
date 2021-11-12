#!/bin/bash

set -ex

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install \
  ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace --namespace ingress-nginx \
  --version v3.39.0 \
  --set controller.kind=DaemonSet \
  --set defaultBackend.replicaCount=3 \
  --set rbac.create=true
