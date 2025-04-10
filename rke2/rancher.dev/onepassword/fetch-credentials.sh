#!/bin/bash

set -e

if ! env | grep OP_SESSION_ > /dev/null 2>&1; then
  eval "$(op signin)"
fi
ONEPASS_CREDS="$(op read "op://1pass connect/connect.dev.lsst.org Credentials File/1password-credentials.json")"

cat > secret-op-credentials.yaml <<END
---
apiVersion: v1
kind: Secret
metadata:
  name: op-credentials
  namespace: onepassword-connect
type: Opaque
# The credentials end up being double base64 encoded...
stringData:
  1password-credentials.json: $(echo "${ONEPASS_CREDS}" | base64 -w 0)
END
