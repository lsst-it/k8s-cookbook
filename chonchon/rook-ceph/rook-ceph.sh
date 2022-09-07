#!/bin/bash

set -ex

VERSION='1.9.9'

print_error() {
  >&2 echo -e "$@"
}

fail() {
  local code=${2:-1}
  [[ -n $1 ]] && print_error "$1"
  # shellcheck disable=SC2086
  exit $code
}

has_cmd() {
  local command=${1?command is required}
  command -v "$command" > /dev/null 2>&1
}

require_cmds() {
  local cmds=("${@?at least one command is required}")
  local errors=()

  # accumulate a list of all missing commands before failing to reduce end-user
  # install/retry cycles
  for c in "${cmds[@]}"; do
    if ! has_cmd "$c"; then
      errors+=("prog: ${c} is required")
    fi
  done

  if [[ ${#errors[@]} -ne 0 ]]; then
    for e in "${errors[@]}"; do
      print_error "$e"
    done

    fail 'failed because of missing commands'
  fi
}

cephtoolbox() {
  kubectl -n rook-ceph exec -it "$(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}')" -- "$@"
}

ceph() {
  cephtoolbox ceph "$@"
}

waitfor() {
  xtrace=$(set +o|grep xtrace); set +x
  local ns=${1?namespace is required}; shift
  local type=${1?type is required}; shift

  echo "Waiting for $type $*"
  # wait for resource to exist. See: https://github.com/kubernetes/kubernetes/issues/83242
  until kubectl -n "$ns" get "$type" "$@" -o=jsonpath='{.items[0].metadata.name}' >/dev/null 2>&1; do
    echo "Waiting for $type $*"
    sleep 1
  done
  eval "$xtrace"
}

waitforpod() {
  xtrace=$(set +o|grep xtrace); set +x
  local ns=${1?namespace is required}; shift

  # wait for pod to exist
  waitfor "$ns" pod "$@"

  # wait for pod to be ready
  kubectl -n rook-ceph wait --for=condition=ready --timeout=180s pod "$@"
  eval "$xtrace"
}

require_cmds helm kubectl

helm repo add rook-release https://charts.rook.io/release
helm repo update

# Uncomment to manually update CRDs.  If this is run prior to helm as a clean
# install, helm will error as the CRDs will not be correctly labeled.
#kubectl apply -f https://raw.githubusercontent.com/rook/rook/v${VERSION}/deploy/examples/crds.yaml

helm upgrade --install \
  --atomic \
  rook-ceph rook-release/rook-ceph \
  --create-namespace --namespace rook-ceph \
  --version "v${VERSION}" \
  -f ./rook-ceph-values.yaml

helm upgrade --install \
  --atomic \
  rook-ceph-cluster rook-release/rook-ceph-cluster \
  --create-namespace --namespace rook-ceph \
  --set operatorNamespace=rook-ceph \
  --version "v${VERSION}" \
  -f ./rook-ceph-cluster-values.yaml

waitfor rook-ceph secret rook-ceph-dashboard-password
set +x
echo "===================="
echo "dashboard passphrase"
echo "===================="
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
echo "===================="
set -x

# enable ceph orchestrator for nfs
# as of 1.9.9, this is needed to enable configuration of nfs exports via both
# the dashboard and the cli
# https://rook.io/docs/rook/v1.9/CRDs/ceph-nfs-crd/?h=nfs#enable-the-ceph-orchestrator-if-necessary
waitforpod rook-ceph -l app=rook-ceph-tools
ceph mgr module enable rook
ceph mgr module enable nfs
ceph orch set backend rook

# --- customize below this line ---

# lfa/s3
kubectl apply -f s3/object_store.yaml
kubectl apply -f s3/ingress.yaml

# vim: tabstop=2 shiftwidth=2 expandtab
