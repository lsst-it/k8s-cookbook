#!/bin/env bash

set -ex

kubectl apply -f resources/svc_account.yaml
kubectl apply -f resources/clusterrolebinding.yaml
kubectl apply -f resources/role.yaml
kubectl apply -f resources/rolebinding.yaml
kubectl apply -f resources/svc.yaml
kubectl apply -f resources/deployment.yaml
kubectl apply -f resources/job.yaml
kubectl apply -f resources/backupstoragelocation.yaml
kubectl apply -f resources/volumesnapshotlocation.yaml
