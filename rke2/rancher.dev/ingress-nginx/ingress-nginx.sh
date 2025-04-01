#!/bin/bash

set -xe

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --version 4.12.1 \
  --namespace ingress-nginx --create-namespace \
  -f values.yaml \
  --atomic \
  --timeout 60s --wait
