#!/bin/bash

set -ex

helm repo add onepassword-connect https://1password.github.io/connect-helm-charts
helm repo update

helm upgrade --install \
  onepassword-connect onepassword-connect/connect \
  --create-namespace --namespace onepassword-connect \
  --version v1.14.0 \
  --atomic \
  --set-file connect.credentials=1password-credentials.json \
  -f ./values.yaml
