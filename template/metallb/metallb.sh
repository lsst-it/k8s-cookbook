#!/bin/bash
set -xe

# change back to repo add because when adding --repo it does a temp and quick fetch,
# but if the index.yaml is too big, it fails and doesnt found the version. (bug)

helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm upgrade --install metallb metallb/metallb \
  --version 0.14.9 \
  --namespace metallb-system \
  --create-namespace \
  --atomic \
  --timeout 600s \
  --wait

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=metallb -n metallb-system --timeout=180s

kubectl apply -f ipaddresspool-ingress.yaml
