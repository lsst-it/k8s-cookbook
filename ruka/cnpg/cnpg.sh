#!/bin/bash

set -xe

# Install cloudnativePG on cluster
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg

# create namespace for deployment
kubectl create namespace cloudnativepg

# Secrets - app user - postgres user - AWS account for backups
cat << END | kubectl apply -f -
apiVersion: v1
data:
  password: $(echo -n ${USER_PASSWORD}" | base64)
  username: $(echo "app" | base64)
kind: Secret
metadata:
  name: cnpg-cluster-app-user
  namespace: cloudnativepg
type: kubernetes.io/basic-auth
---
apiVersion: v1
data:
  password: $(echo -n "${SUPERUSER_PASSWORD}" | base64)
  username: $(echo "postgres" | base64)
kind: Secret
metadata:
  name: cnpg-cluster-superuser
  namespace: cloudnativepg
type: kubernetes.io/basic-auth
---
apiVersion: v1
data:
  ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
  ACCESS_SECRET_KEY: ${AWS_ACCESS_SECRET_KEY}
kind: Secret
metadata:
  name: cnpg-aws-creds
  namespace: cloudnativepg
type: Opaque
END

# deployment - first time? or recovery? (use cnpg-recovery.yaml for recovery)
cat > deploy.yaml << END
# Cluster Definition
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cnpg-cluster
  namespace: cloudnativepg
spec:
  instances: 3
  #startDelay: 300
  #stopDelay: 300

  bootstrap:
    initdb:
      database: app
      owner: app
      secret:
        name: cnpg-cluster-app-user

  backup:
    barmanObjectStore:
      destinationPath: ${AWS_ACCESS_BUCKET}
      s3Credentials:
        accessKeyId:
          name: cnpg-aws-creds
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: cnpg-aws-creds
          key: ACCESS_SECRET_KEY
      wal:
          compression: gzip

    retentionPolicy: "90d"

  superuserSecret:
    name: cnpg-cluster-superuser

# Resources and Storage Needs to be Adjust!

  storage:
    size: 10Gi
  
  monitoring:
    enablePodMonitor: true
END
kubectl apply -f deploy.yaml
kubectl apply -f cnpg-scheduledbackups.yaml

# We need to setup ingress and expose the service
