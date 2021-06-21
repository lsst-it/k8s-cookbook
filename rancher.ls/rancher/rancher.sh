#!/bin/bash

set -ex

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

kubectl create namespace cattle-system --dry-run -o yaml | kubectl apply -f -

helm upgrade rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.ls.lsst.org \
  --set ingress.tls.source=secret \
  --set ingress.extraAnnotations."cert-manager\.io/cluster-issuer"=letsencrypt \
  --version v2.5.8

kubectl -n cattle-system rollout status deploy/rancher
