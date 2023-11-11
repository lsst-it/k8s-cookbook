#!/usr/bin/env bash

MIMIR_S3_CONFIG="mimir.structuredConfig.common.storage.s3"

set -ex

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install ayekan-mimir grafana/mimir-distributed \
     --set "${MIMIR_S3_CONFIG}.access_key_id=${O11Y_S3_KEY_ID}" \
     --set "${MIMIR_S3_CONFIG}.secret_access_key=${O11Y_S3_ACCESS_KEY}" \
     --set "${MIMIR_S3_CONFIG}.endpoint=${O11Y_S3_ENDPOINT}" \
     --create-namespace --namespace mimir \
     --atomic --timeout 30m0s \
     -f ./values.yaml
