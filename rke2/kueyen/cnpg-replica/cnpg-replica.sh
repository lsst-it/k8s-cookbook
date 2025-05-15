#!/bin/bash

set -xe

# Install cloudnativePG on cluster (chart 0.17.0 installs 1.19.0 cnpg)
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --version="0.17.0" \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg \
  --atomic

# Install cnpg-plugin for kubectl (future reference)
# curl -L https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v1.19.0/kubectl-cnpg_1.19.0_linux_x86_64.rpm --output kube-plugin.rpm
# yum -y --disablerepo=* localinstall kube-plugin.rpm #needs sudo

# create namespace for deployment
kubectl create namespace cloudnativepg

# Secret for the access to the external cluster
kubectl apply -f externalsecret-source-db-replica-user.yaml

# deploy away!
kubectl apply -f cluster-replica-cluster.yaml
# loadBalancer
kubectl apply -f cnpg-loadbalancer.yaml
