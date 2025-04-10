#!/bin/bash
set -xe

helm upgrade --install onepassword-connect connect \
  --repo https://1password.github.io/connect-helm-charts \
  --version 1.17.0 \
  --namespace onepassword-connect --create-namespace \
  -f values.yaml \
  --timeout 60s --wait
