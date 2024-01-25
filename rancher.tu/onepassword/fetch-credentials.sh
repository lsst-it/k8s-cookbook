#!/bin/bash

set -e

eval "$(op signin)"
op read "op://1pass connect/connect.tu.lsst.org Credentials File/1password-credentials.json" --out-file 1password-credentials.json
