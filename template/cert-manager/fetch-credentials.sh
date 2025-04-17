#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source onepass_item.sh

if ! env | grep -q '^OP_SESSION_'; then
  eval "$(op signin)"
fi

ACCESS_KEY=$(op item get "$ITEM_NAME" --field "username" --reveal)
SECRET_KEY=$(op item get "$ITEM_NAME" --field "password" --reveal)

ACCESS_KEY_B64=$(printf "%s" "$ACCESS_KEY" | base64)
SECRET_KEY_B64=$(printf "%s" "$SECRET_KEY" | base64)

cat <<EOF > secret-aws.yaml
apiVersion: v1
kind: Secret
metadata:
  name: route53
  namespace: cert-manager
type: Opaque
data:
  AWS_ACCESS_KEY_ID: ${ACCESS_KEY_B64}
  AWS_SECRET_ACCESS_KEY: ${SECRET_KEY_B64}
EOF
