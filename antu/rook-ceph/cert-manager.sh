#!/bin/bash

set -e

print_error() {
  >&2 echo -e "$@"
}

fail() {
  local code=${2:-1}
  [[ -n $1 ]] && print_error "$1"
  # shellcheck disable=SC2086
  exit $code
}

check_vars() {
  local req_vars=(
    AWS_ACCESS_KEY_ID
    AWS_DEFAULT_REGION
    DNS_ZONE
    EMAIL
    HOSTED_ZONE_ID
  )

  local err
  for v in "${req_vars[@]}"; do
    [[ ! -v $v ]] && err="${err}Missing required env variable: ${v}\n"
  done

  [[ -n $err ]] && fail "$err"

  # need explicit return status incase the last -z check returns 1
  return 0
}

check_vars

cat > secret.yaml << END
apiVersion: v1
kind: Secret
metadata:
  name: aws-route53
  namespace: rook-ceph
data:
  aws_key: $(echo "${AWS_SECRET_ACCESS_KEY}" | base64)
END

cat > letsencrypt.yaml << END
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt
  namespace: rook-ceph
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

cat > letsencrypt-staging.yaml << END
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-staging
  namespace: rook-ceph
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
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

kubectl create namespace rook-ceph --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f secret.yaml
# need to wait for the CA to be injected
sleep 20
kubectl apply -f letsencrypt.yaml
kubectl apply -f letsencrypt-staging.yaml

kubectl wait --for=condition=ready --timeout=180s -n rook-ceph issuer/letsencrypt
kubectl wait --for=condition=ready --timeout=180s -n rook-ceph issuer/letsencrypt-staging
