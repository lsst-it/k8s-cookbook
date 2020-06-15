#!/bin/bash

set -ex

#
# copied from https://hub.helm.sh/charts/jetstack/cert-manager
#

## IMPORTANT: you MUST install the cert-manager CRDs **before** installing the
## cert-manager Helm chart
kubectl apply --validate=false \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml

## Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Create the namespace for cert-manager
kubectl create namespace cert-manager

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager