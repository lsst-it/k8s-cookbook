#!/bin/bash

set -ex

helm repo add stevehipwell https://stevehipwell.github.io/helm-charts/
helm repo update

helm upgrade --install my-nexus3 stevehipwell/nexus3 \
    --version 4.40.0 \
    --create-namespace --namespace nexus \
    --atomic \
    --values ./values.yaml
