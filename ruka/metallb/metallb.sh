#!/bin/bash

set -ex

kubectl create namespace metallb-system
kubectl label namespace metallb-system pod-security.kubernetes.io/enforce: privileged
kubectl label namespace metallb-system pod-security.kubernetes.io/audit: privileged
kubectl label namespace metallb-system pod-security.kubernetes.io/warn: privileged

helm repo add metallb https://metallb.github.io/metallb
helm upgrade --install --namespace metallb-system \
    --create-namespace \
    metallb metallb/metallb \
    --atomic --version 0.13.7
kubectl apply -f ippool.yaml
