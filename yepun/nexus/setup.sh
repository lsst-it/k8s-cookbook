#!/bin/bash

set -ex

helm repo add stevehipwell https://stevehipwell.github.io/helm-charts/
helm repo update

helm install my-nexus3 stevehipwell/nexus3 \
    --version 4.39.0 \
    --create-namespace --namespace nexus \
    --atomic \
    --values ./values.yaml
