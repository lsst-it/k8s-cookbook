#!/bin/env bash

# fix version of keycloak chart
VERSION='17.3.1'

# make sure the S3 credentials are setup as env. variable
if [[ -v KEYCLOAK_UI_PASS && -v KEYCLOAK_PG_PASS && -v KEYCLOAK_INGRESS && -v POSTGRES_HOST ]]; then
    echo "Environmental variables are ok, carry on..."
else
    echo "the environment variables do not exist"
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

# create values file
cat > keycloak-values.yaml << END
extraEnvVars:
  - name: KC_HEALTH_ENABLED
    value: "true"
  - name: KEYCLOAK_LOGLEVEL
    value: INFO
  - name: KEYCLOAK_PRODUCTION
    value: "true"
  - name: KEYCLOAK_PROXY
    value: "edge"

ingress:
  enabled: true
  servicePort: http
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/issuer: letsencrypt
  hostname: ${KEYCLOAK_INGRESS}
  tls: true

auth:
  adminUser: admin
  existingSecret: keycloak-admin
  passwordSecretKey: password

postgresql:
  enabled: false

externalDatabase:
  host: ${POSTGRES_HOST}
  port: 5432
  user: keycloak
  database: keycloak
  existingSecret: keycloak-pg
  existingSecretPasswordKey: password
END

# add helm repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# install keycloack
helm upgrade --install keycloak bitnami/keycloak \
    --namespace keycloak \
    --version ${VERSION} \
    --values keycloak-values.yaml
