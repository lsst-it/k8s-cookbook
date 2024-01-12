#!/bin/bash

set -ex

helm repo add uptime-kuma https://dirsigler.github.io/uptime-kuma-helm
helm repo update

helm install my-uptime-kuma uptime-kuma/uptime-kuma \
    --version 2.17.0 \
    --create-namespace --namespace kuma \
    --atomic

kubectl apply -f ingress-kuma.yaml
