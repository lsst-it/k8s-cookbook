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

tmpdir=$(mktemp -d -t "$(basename BASH_SOURCE)-XXXXXXXX")
tmpfile="$tmpdir/foo}"
# shellcheck disable=SC2064
trap "{ rm -rf $tmpdir; }" EXIT

ENDPOINT='--ca-bundle /etc/ssl/certs/ca-bundle.crt --endpoint-url https://s3.tu.lsst.org'

# shellcheck disable=SC2086
aws s3 $ENDPOINT --region lfa mb s3://s3demo
dd if=/dev/zero of="$tmpfile" bs=1M count=1K
# shellcheck disable=SC2086
time aws s3 $ENDPOINT cp "$tmpfile" s3://s3demo
rm "$tmpfile"
# shellcheck disable=SC2086
aws s3 $ENDPOINT ls s3://s3demo
# shellcheck disable=SC2086
aws s3 $ENDPOINT rm s3://s3demo/foo
# shellcheck disable=SC2086
aws s3 $ENDPOINT rb s3://s3demo
