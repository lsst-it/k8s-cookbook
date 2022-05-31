#!/bin/env bash

set -ex

kubectl delete -f resources/volumesnapshotlocation.yaml
kubectl delete -f resources/backupstoragelocation.yaml
kubectl delete -f resources/job.yaml
kubectl delete -f resources/deployment.yaml
kubectl delete -f resources/svc.yaml
kubectl delete -f resources/rolebinding.yaml
kubectl delete -f resources/role.yaml
kubectl delete -f resources/clusterrolebinding.yaml
kubectl delete -f resources/svc_account.yaml
kubectl delete ns velero
