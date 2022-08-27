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
  # shellcheck disable=SC2068
  kubectl -n rook-ceph exec -it "$(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}')" -- $@
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

kubectl apply -f cephblockpool.yaml
kubectl apply -f ceph-storageclass.yaml
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# dashboard creds
while :; do
  kubectl -n rook-ceph get pod -l app=rook-ceph-mgr,rook_cluster=rook-ceph && break
  sleep 3
done
kubectl -n rook-ceph wait --for=condition=ready --timeout=180s pod -l app=rook-ceph-mgr,rook_cluster=rook-ceph

set +x
echo "===================="
echo "dashboard passphrase"
echo "===================="
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
echo "===================="
set -x

# cephfs w/ nfs
kubectl apply -f nfs/cephfs-jhome.yaml
kubectl apply -f nfs/cephfs-lsstdata.yaml
kubectl apply -f nfs/cephfs-project.yaml
kubectl apply -f nfs/cephfs-scratch.yaml

# lfa/s3
kubectl apply -f s3/object_store.yaml
kubectl apply -f s3/ingress.yaml

# enable ceph orchestrator for nfs
# as of 1.9.9, this is needed to enable configuration of nfs exports via both
# the dashboard and the cli
# https://rook.io/docs/rook/v1.9/CRDs/ceph-nfs-crd/?h=nfs#enable-the-ceph-orchestrator-if-necessary
cephtoolbox ceph mgr module enable rook
cephtoolbox ceph mgr module enable nfs
cephtoolbox ceph orch set backend rook

cephtoolbox ceph nfs export rm jhome /jhome
cephtoolbox ceph nfs export create cephfs jhome /jhome jhome
cephtoolbox ceph nfs export rm lsstdata /lsstdata
cephtoolbox ceph nfs export create cephfs lsstdata /lsstdata lsstdata
cephtoolbox ceph nfs export rm project /project
cephtoolbox ceph nfs export create cephfs project /project project
cephtoolbox ceph nfs export rm scratch /scratch
cephtoolbox ceph nfs export create cephfs scratch /scratch scratch

# vim: tabstop=2 shiftwidth=2 expandtab
