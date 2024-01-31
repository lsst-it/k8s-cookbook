#!/bin/bash

set -e

if ! env | grep OP_SESSION_ > /dev/null 2>&1; then
  eval "$(op signin)"
fi
op read "op://1pass connect/connect.cp.lsst.org Credentials File/1password-credentials.json" --out-file 1password-credentials.json
