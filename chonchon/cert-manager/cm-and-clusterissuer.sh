#!/bin/bash

set -ex

kubectl create ns cert-manager
helm repo add jetstack https://charts.jetstack.io
# helm managment of the CRDs did not work when tested
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.crds.yaml
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.1.0 \
  --set installCRDS=false

cat > secret.yaml << END
apiVersion: v1
kind: Secret
metadata:
  name: aws-route53
  namespace: cert-manager
data:
  aws_key: $(echo ${AWS_SECRET_ACCESS_KEY} | base64)
END

cat > letsencrypt.yaml << END
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt
    email: ${EMAIL}
    solvers:
    - selector:
        dnsZones:
          - "${DNS_ZONE}"
      dns01:
        route53:
          region: ${AWS_DEFAULT_REGION}
          hostedZoneID: ${HOSTED_ZONE_ID}
          accessKeyID: ${AWS_ACCESS_KEY_ID}
          secretAccessKeySecretRef:
            name: aws-route53
            key: aws_key
END

kubectl apply -f secret.yaml
# need to wait for the CA to be injected
sleep 20
kubectl apply -f letsencrypt.yaml
