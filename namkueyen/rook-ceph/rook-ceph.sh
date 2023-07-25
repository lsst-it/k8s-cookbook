#!/bin/bash

set -ex

VERSION='1.11.2'

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

# run command until it exits 0
waitforcmd() {
  xtrace=$(set +o|grep xtrace); set +x
  local wait=${1?sleep interval}; shift

  echo "Waiting for $*"

  until "$@" > /dev/null 2>&1; do
    echo "Waiting for $*"
    sleep "$wait";
  done

  eval "$xtrace"
}

waitforkube() {
  xtrace=$(set +o|grep xtrace); set +x
  local ns=${1?namespace is required}; shift
  local type=${1?type is required}; shift

  # wait for resource to exist. See: https://github.com/kubernetes/kubernetes/issues/83242
  waitforcmd 2 kubectl -n "$ns" get "$type" "$@" -o=jsonpath='{.items[0].metadata.name}'

  eval "$xtrace"
}

waitforpod() {
  xtrace=$(set +o|grep xtrace); set +x
  local ns=${1?namespace is required}; shift

  # wait for pod to exist
  waitforkube "$ns" pod "$@"

  # wait for pod to be ready
  kubectl -n rook-ceph wait --for=condition=ready --timeout=180s pod "$@"
  eval "$xtrace"
}

# wait for ceph nfs related resources to be ready
waitfornfs() {
  xtrace=$(set +o|grep xtrace); set +x
  local fs=${1?fs name}; shift

  waitforpod rook-ceph -l app=rook-ceph-nfs,ceph_nfs="$fs"
  waitforpod rook-ceph -l app=rook-ceph-mds,rook_file_system="$fs"
  waitforcmd 2 ceph fs get "$fs"

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

waitforkube rook-ceph secret rook-ceph-dashboard-password
set +x
echo "===================="
echo "dashboard passphrase"
echo "===================="
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
echo "===================="
set -x

# disable ceph rook orechestrator for >= 17.2.1 and >= 16.2.11
# https://rook.io/docs/rook/latest/CRDs/ceph-nfs-crd/#ceph-v1721
waitforpod rook-ceph -l app=rook-ceph-tools
ceph mgr module enable nfs
ceph orch set backend ""
ceph mgr module disable rook

# --- customize below this line ---

kubectl apply -f cephblockpool.yaml
kubectl apply -f ceph-storageclass.yaml
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# cephfs w/ nfs
kubectl apply -f nfs/cephfs-auxtel.yaml
kubectl apply -f nfs/cephfs-comcam.yaml

# lfa/s3
kubectl apply -f s3/object_store.yaml
kubectl apply -f s3/ingress.yaml

waitfornfs auxtel
ceph nfs export rm auxtel /auxtel
ceph nfs export create cephfs auxtel /auxtel auxtel

waitfornfs comcam
ceph nfs export rm comcam /comcam
ceph nfs export create cephfs comcam /comcam comcam

ceph mgr module enable rook
ceph orch set backend rook
ceph device monitoring on
ceph config set global device_failure_prediction_mode local

# vim: tabstop=2 shiftwidth=2 expandtab
