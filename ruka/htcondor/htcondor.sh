#!/bin/bash

if [[ -v HTCPASSWORD ]]; then
    echo "Environmentals are OK!"
else
    echo "Variable for password is missing! Ex: export HTCPASSWORD=testpassword"
    exit 1
fi

kubectl create namespace htcondor || true

cat << END | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: htcondor-pool-password
  namespace: htcondor
type: Opaque
data:
  password: $(echo -n "${HTCPASSWORD}" | base64)
END

kubectl apply -f htcondor-central-manager-deployment.yaml
kubectl apply -f htcondor-central-manager-service.yaml
kubectl apply -f htcondor-schedd-deployment.yaml
kubectl apply -f htcondor-worker-deployment.yaml
