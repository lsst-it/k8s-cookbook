#!/bin/env bash

# fix version of keycloak chart
VERSION='17.3.1'

# make sure the S3 credentials are setup as env. variable
if [[ -v KEYCLOAK_UI_PASS && -v KEYCLOAK_PG_PASS ]]; then
    echo "Environmental variables are ok, carry on..."
else
    echo "Either KEYCLOAK_UI_PASS or KEYCLOAK_PG_PASS (or both) do not exist"
    exit 1
fi

# create namespace if it doesn't exist
kubectl create namespace keycloak || true

# add postgres secret
cat << END | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-pg
  namespace: keycloak
  labels:
    app.kubernetes.io/name: keycloak
    app.kubernetes.io/managed-by: Helm
type: Opaque
data:
  password: $(echo -n "${KEYCLOAK_PG_PASS}" | base64)
  username: $(echo -n "keycloak" | base64)
END

# add keycloak ui secret
cat << END | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-admin
  namespace: keycloak
  labels:
    app.kubernetes.io/name: keycloak
    app.kubernetes.io/managed-by: Helm
type: Opaque
data:
  password: $(echo -n "${KEYCLOAK_UI_PASS}" | base64)
  username: $(echo -n "admin" | base64)
END

# add helm repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# install keycloack
helm upgrade --install keycloak bitnami/keycloak \
    --namespace keycloak \
    --version ${VERSION} \
    --values keycloak-values.yaml
