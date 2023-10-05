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

# create namespace for deployment
kubectl create namespace cloudnativepg

# Secrets - app user - postgres user - AWS account for backups
cat << END | kubectl apply -f -
---
apiVersion: v1
data:
  password: $(echo -n "${SUPERUSER_PASSWORD}" | base64)
  username: $(echo -n "postgres" | base64)
kind: Secret
metadata:
  name: cnpg-cluster-superuser
  namespace: cloudnativepg
type: kubernetes.io/basic-auth
END

# Deployment FIRST TIME ONLY
cat > deploy.yaml << END
# Cluster Definition
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cnpg-cluster
  namespace: cloudnativepg
spec:
  imageName: ghcr.io/cloudnative-pg/postgresql:14.5
  imagePullPolicy: Always

  instances: 2

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

  superuserSecret:
    name: cnpg-cluster-superuser

  storage:
    size: 1Gi

  monitoring:
    enablePodMonitor: true
END
# Deploys the cluster
kubectl apply -f deploy.yaml
# Sets the service to connect
kubectl apply -f cnpg-lb.yaml
