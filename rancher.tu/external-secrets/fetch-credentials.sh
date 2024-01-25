#!/bin/bash

set -e

eval "$(op signin)"
ONEPASS_TOKEN="$(op item get "connect.tu.lsst.org Access Token: rancher.tu.lsst.org" --fields credential)"

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
