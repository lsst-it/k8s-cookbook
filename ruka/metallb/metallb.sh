#!/bin/bash

set -ex
helm repo add metallb https://metallb.github.io/metallb
helm upgrade --install --namespace metallb-system \
    --create-namespace \
    metallb metallb/metallb \
    --atomic --version 0.13.7
kubectl apply -f ippool.yaml
