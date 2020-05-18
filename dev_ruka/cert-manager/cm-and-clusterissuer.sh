#!/bin/bash

set -ex

kubectl create ns cert-manager
helm repo add jetstack https://charts.jetstack.io
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml --validate=false
helm install cert-manager -n cert-manager jetstack/cert-manager
cat > secret.yaml << END
apiVersion: v1
kind: Secret
metadata:
  name: aws-route53
  namespace: cert-manager
data:
  aws_key: $(AWS_SECRET_KEY)

END
kubectl apply -f secret.yaml
cat > letsencrypt.yaml << END
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory 
    privateKeySecretRef:
      name: letsencrypt
    email: $(EMAIL)
    solvers:
    - selector:
        dnsZones:
          - "$(DNS_ZONE)"
      dns01:
        route53:
          region: $(REGION)
          hostedZoneID: $(HOSTED_ZONE_ID)
          accessKeyID: $(AWS_ACCESS_KEY) 
          secretAccessKeySecretRef: 
            name: aws-route53
            key: aws_key 
END
kubectl apply -f letsencrypt