#!/bin/bash

set -e

if ! env | grep OP_SESSION_ > /dev/null 2>&1; then
  eval "$(op signin)"
fi
ONEPASS_TOKEN="$(op item get "connect.tu.lsst.org Access Token: pillan.tu.lsst.org" --fields credential)"

cat > secret-onepassword-token.yaml << END
---
apiVersion: v1
kind: Secret
metadata:
  name: onepassword-connect-token
  namespace: external-secrets
type: Opaque
stringData:
  token: ${ONEPASS_TOKEN}
END
