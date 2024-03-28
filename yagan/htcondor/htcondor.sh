#!/bin/bash
kubectl create namespace htcondor || true
kubectl apply -f externalsecret-htcondor-pool-password.yaml
kubectl apply -f htcondor-central-manager-deployment.yaml
kubectl apply -f htcondor-central-manager-service.yaml
kubectl apply -f htcondor-worker-deployment.yaml
