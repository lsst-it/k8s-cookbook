#!/bin/bash

set -e

eval "$(op signin)"
ONEPASS_TOKEN="$(op item get "connect.dev.lsst.org Access Token: kueyen.dev.lsst.org" --fields credential)"

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
