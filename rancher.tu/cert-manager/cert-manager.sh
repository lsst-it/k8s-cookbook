#!/bin/bash

set -exu

## cert-manager Helm chart
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml --validate=false

## Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Create the namespace for cert-manager
kubectl create namespace cert-manager

# Update your local Helm chart repository cache
helm repo update

# Apply the secret with the AWS key
kubectl apply -f secret.yaml

# Install the ClusterIssuer
kubectl apply -f letsencrypt.yaml

# Install the cert-manager Helm chart
helm install cert-manager -n cert-manager jetstack/cert-manager
