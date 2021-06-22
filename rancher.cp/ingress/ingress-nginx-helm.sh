#!/bin/bash

set -ex

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

kubectl create namespace ingress-nginx

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --version v3.23.0 \
  --set controller.kind=DaemonSet \
  --set defaultBackend.replicaCount=3 \
  --set rbac.create=true
