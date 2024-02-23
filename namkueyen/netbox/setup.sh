#!/bin/bash

set -ex

helm repo add startechnica https://startechnica.github.io/apps
helm repo update

helm upgrade --install netbox startechnica/netbox \
    --version 5.0.6 \
    --create-namespace --namespace netbox \
    --atomic \
    --values ./values.yaml
