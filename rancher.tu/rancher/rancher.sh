#!/bin/bash

set -ex

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

kubectl create namespace cattle-system

helm install rancher  -n cattle-system rancher-stable/rancher -f values.yaml
  
kubectl -n cattle-system rollout status deploy/rancher
