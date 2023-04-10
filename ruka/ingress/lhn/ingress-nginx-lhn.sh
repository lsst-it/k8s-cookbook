#!/bin/bash

set -ex

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install \
  ingress-nginx-lhn ingress-nginx/ingress-nginx \
  --create-namespace --namespace ingress-nginx-lhn \
  --set controller.ingressClass="nginx-lhn" \
  --set controller.ingressClassResource.name="nginx-lhn" \
  --set controller.service.annotations."metallb\.universe\.tf\/address-pool"=lhn \
  --version v4.2.1 \
  --set controller.kind=DaemonSet \
  --set defaultBackend.replicaCount=3 \
  --set rbac.create=true \
  --atomic

kubectl apply -f ingress-s3-lhn.yaml
