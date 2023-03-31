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
cat << END | kubectl apply -f -
---
apiVersion: v1
data:
  password: $(echo -n "${SUPERUSER_PASSWORD}" | base64)
kind: Secret
metadata:
  name: source-db-replica-user
  namespace: cloudnativepg
type: kubernetes.io/basic-auth
END

# Deployment FIRST TIME ONLY
cat > deploy.yaml << END
# Cluster Definition
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: replica-cluster
  namespace: cloudnativepg
spec:
  imageName: docker.io/cbarria/cnpgsphere:14.5
  imagePullPolicy: Always

  instances: 3

  postgresql:
    parameters:
      max_connections: "500"
      shared_buffers: 256MB
      idle_session_timeout: 4h
    pg_hba:
      - host all all 139.229.134.0/23 md5
      - host all all 139.229.136.0/21 md5
      - host all all 139.229.144.0/20 md5
      - host all all 139.229.160.0/19 md5
      - host all all 139.229.192.0/18 md5
      - host all all 140.252.146.0/23 md5

  bootstrap:
    pg_basebackup:
      source: cnpg-cluster

  replica:
    enabled: true
    source: cnpg-cluster

  externalClusters:
  - name: cnpg-cluster
    connectionParameters:
      host: ${CNPGHOST}
      user: postgres
    password:
      name: source-db-replica-user
      key: password

# Resources and Storage Needs to be Adjust!

  storage:
    size: 5Gi
END
# deploy away!
kubectl apply -f deploy.yaml
# loadBalancer
kubectl apply -f cnpg-loadbalancer.yaml
