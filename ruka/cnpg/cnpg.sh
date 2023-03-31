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
cat << END | kubectl apply -f -
apiVersion: v1
data:
  password: $(echo -n "${USER_PASSWORD}" | base64)
  username: $(echo -n "app" | base64)
kind: Secret
metadata:
  name: cnpg-cluster-app
  namespace: cloudnativepg
type: kubernetes.io/basic-auth
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
---
apiVersion: v1
data:
  ACCESS_KEY_ID: $(echo -n "${AWS_ACCESS_KEY_ID}" | base64)
  ACCESS_SECRET_KEY: $(echo -n "${AWS_SECRET_ACCESS_KEY}" | base64)
kind: Secret
metadata:
  name: cnpg-aws-creds
  namespace: cloudnativepg
type: Opaque
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
  imageName: docker.io/cbarria/cnpgsphere:14.5
  imagePullPolicy: Always

  instances: 3

  postgresql:
    parameters:
      max_connections: "500"
      shared_buffers: 256MB
      idle_session_timeout: 4h
    pg_hba:
      - host replication postgres all md5
      - host all all 139.229.134.0/23 md5
      - host all all 139.229.136.0/21 md5
      - host all all 139.229.144.0/20 md5
      - host all all 139.229.160.0/19 md5
      - host all all 139.229.192.0/18 md5
      - host all all 140.252.146.0/23 md5

  bootstrap:
    initdb:
      database: app
      owner: app
      secret:
        name: cnpg-cluster-app

  backup:
    barmanObjectStore:
      destinationPath: s3://cnpg-backups-dev
      s3Credentials:
        accessKeyId:
          name: cnpg-aws-creds
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: cnpg-aws-creds
          key: ACCESS_SECRET_KEY
      wal:
          compression: gzip

    retentionPolicy: "60d"

  superuserSecret:
    name: cnpg-cluster-superuser

# Resources and Storage Needs to be Adjust!

  storage:
    size: 5Gi

  monitoring:
    enablePodMonitor: true
END
#this needs to be changed to apply cnpg-recovery.yaml for recovery on existing cluster, 
#refer to the file because s3 backup folder needs to be changed.
kubectl apply -f cnpg-recovery.yaml
#pgBouncer exposed with loadBalancer
kubectl apply -f pgbouncer-loadbalancer.yaml
#loadBalancer for the replica cluster connection
kubectl apply -f cnpg-replica-lb.yaml
#Schedule Backup Jobs to S3
kubectl apply -f cnpg-scheduledbackups.yaml
