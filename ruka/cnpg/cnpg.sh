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

# Secrets - app user - postgres user - AWS account for backups
kubectl apply -f externalsecret-cnpg-cluster-app.yaml
kubectl apply -f externalsecret-cnpg-cluster-superuser.yaml
kubectl apply -f externalsecret-cnpg-aws-creds.yaml

# Deployment FIRST TIME ONLY
kubectl apply -f cluster-cnpg-cluster.yaml

#this needs to be changed to apply cnpg-recovery.yaml for recovery on existing cluster,
#refer to the file because s3 backup folder needs to be changed.
kubectl apply -f cnpg-recovery.yaml
#pgBouncer exposed with loadBalancer
kubectl apply -f pgbouncer-loadbalancer.yaml
#loadBalancer for the replica cluster connection
kubectl apply -f cnpg-replica-lb.yaml
#Schedule Backup Jobs to S3
kubectl apply -f cnpg-scheduledbackups.yaml
