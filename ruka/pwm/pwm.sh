#!/bin/bash

set -ex
helm repo add truecharts https://charts.truecharts.org/
helm upgrade --install --namespace pwm \
  --create-namespace \
  pwm truecharts/pwm \
  --atomic --version 2.0.9 \
  --values - <<EOF
image:
  repository: lsstit/pwm-webapp
  tag: latest@sha256:1693428e9a02ad73613caba52ff211f5dffef1133304354ac9d42b927a5c6362
persistence:
  appdata:
    enabled: true
    mountPath: /config
service:
  main:
    ports:
      main:
        port: 8443
        protocol: TCP
        targetPort: 8443
EOF

kubectl apply -f ingress.yaml
