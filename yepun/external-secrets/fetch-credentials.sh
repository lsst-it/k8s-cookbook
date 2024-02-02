#!/bin/bash

set -e

if ! env | grep OP_SESSION_ > /dev/null 2>&1; then
  eval "$(op signin)"
fi
ONEPASS_TOKEN="$(op item get "connect.cp.lsst.org Access Token: yepun.cp.lsst.org" --fields credential)"

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
