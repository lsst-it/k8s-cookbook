#!/bin/bash

set -ex

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install \
  ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace --namespace ingress-nginx \
  --version v4.5.2 \
  --set controller.kind=DaemonSet \
  --set controller.service.annotations."metallb\.universe\.tf\/loadBalancerIPs"=139.229.144.39 \
  --set defaultBackend.replicaCount=3 \
  --set rbac.create=true \
  --atomic
