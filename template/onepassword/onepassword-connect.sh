#!/bin/bash

set -ex

kubectl create namespace onepassword-connect --dry-run=client -o yaml | kubectl apply --server-side -f -
kubectl apply --server-side -f secret-op-credentials.yaml
