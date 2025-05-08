#!/bin/bash

set -ex

kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f secret-onepassword-connect-token.yaml
