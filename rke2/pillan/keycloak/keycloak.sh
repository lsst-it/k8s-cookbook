#!/bin/env bash

set -ex

VERSION='17.3.1'

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

kubectl create namespace keycloak || true

kubectl apply -f externalsecret-route53.yaml
kubectl apply -f issuer-letsencrypt-staging.yaml
kubectl apply -f issuer-letsencrypt.yaml
kubectl apply -f externalsecret-keycloak-pg.yaml
kubectl apply -f externalsecret-keycloak-admin.yaml

helm upgrade --install \
  keycloak bitnami/keycloak \
  --create-namespace --namespace keycloak \
  --version ${VERSION} \
  --values values.yaml \
  --atomic
