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
	AWS_SECRET_ACCESS_KEY
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

set -x

aws s3 --endpoint-url https://s3.tu.lsst.org --region lfa mb s3://s3demo
touch foo
aws s3 --endpoint-url https://s3.tu.lsst.org cp foo s3://s3demo
aws s3 --endpoint-url https://s3.tu.lsst.org ls s3://s3demo
aws s3 --endpoint-url https://s3.tu.lsst.org rm s3://s3demo/foo
aws s3 --endpoint-url https://s3.tu.lsst.org rb s3://s3demo
