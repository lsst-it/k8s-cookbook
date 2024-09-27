#!/bin/bash

set -e

# shellcheck disable=SC1091
source onepass_item.sh

if ! env | grep OP_SESSION_ > /dev/null 2>&1; then
  eval "$(op signin)"
fi

ONEPASS_TOKEN="$(op item get "$ONEPASS_ITEM" --fields credential --reveal)"

cat > secret-onepassword-connect-token.yaml << END
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
