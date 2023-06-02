#!/bin/bash
set -ex
helm repo add nautobot https://nautobot.github.io/helm-charts/
helm upgrade --install nautobot nautobot/nautobot --create-namespace --namespace nautobot \
    --set postgresql.auth.password="${postgres_pass:-}" --set redis.auth.password="${redis_pass:-}" \
    --atomic --version 2.0.2
kubectl apply -f ingress.yaml
