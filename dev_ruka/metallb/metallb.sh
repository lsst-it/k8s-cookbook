#!/bin/bash

set -ex

kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml
kubectl apply -f ./mlb-l2.yaml
