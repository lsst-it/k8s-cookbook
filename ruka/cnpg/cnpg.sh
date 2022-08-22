#!/bin/bash

set -xe

# Install cloudnativePG on cluster
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg

# create namespace for deployment
# kubectl create namespace

# Secrets - app user - postgres user - AWS account for backups
cat << END | kubectl apply -f -
apiVersion: v1
data:
  password: $(printf "${USER_PASSWORD}" | base64)
  username: $(printf "app" | base64)
kind: Secret
metadata:
  name: cnpg-cluster-app-user
type: kubernetes.io/basic-auth
---
apiVersion: v1
data:
  password: $(printf "${SUPERUSER_PASSWORD}" | base64)
  username: $(printf "postgres" | base64)
kind: Secret
metadata:
  name: cnpg-cluster-superuser
type: kubernetes.io/basic-auth
---
apiVersion: v1
data:
  ACCESS_KEY_ID:  $(printf "${AWS_ACCESS_KEY_ID}")
  ACCESS_SECRET_KEY:  $(printf "${AWS_ACCESS_SECRET_KEY}")
kind: Secret
metadata:
  name: cnpg-aws-creds
type: Opaque
END

# deployment - first time? or recovery? (use cnpg-recovery.yaml for recovery)
cat > deploy.yaml << END
# Cluster Definition
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cnpg-cluster
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
      destinationPath: $(printf "${AWS_ACCESS_BUCKET}")
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
---
apiVersion: postgresql.cnpg.io/v1
kind: ScheduledBackup
metadata:
  name: cnpg-backup-scheduled
spec:
  schedule: "0 0 0 * * *"
  backupOwnerReference: self
  cluster:
    name: cnpg-cluster
END
kubectl apply -f deploy.yaml

# We need to setup ingress and expose the service
