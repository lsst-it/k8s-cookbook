#!/bin/bash

set -ex

CHART_VERSION="1.12.2"

helm repo add jetstack https://charts.jetstack.io
helm repo update

# https://cert-manager.io/docs/installation/helm/#crd-installation-advice
kubectl create namespace cert-manager --dry-run -o yaml | kubectl apply -f -
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v${CHART_VERSION}/cert-manager.crds.yaml

helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --create-namespace --namespace cert-manager \
  --version v${CHART_VERSION} \
  --set installCRDS=false \
  --atomic

kubectl apply -f externalsecret-route53.yaml
kubectl apply -f clusterissuer-letsencrypt.yaml
kubectl apply -f clusterissuer-letsencrypt-staging.yaml

kubectl -n cert-manager wait --for=condition=ready --timeout=180s externalsecret/route53
kubectl -n cert-manager wait --for=condition=ready --timeout=180s clusterissuer/letsencrypt
kubectl -n cert-manager wait --for=condition=ready --timeout=180s clusterissuer/letsencrypt-staging
