#!/bin/bash
#
# Install or upgrade Rancher.
#
# Run it from rke2/rancher.<site>/rancher/, which holds the site's:
#   values.yaml       Helm values (hostname, ingress, extraEnv)
#   rancher-version   Rancher chart version for this site, e.g. v2.14.3
#
# Environment:
#   KUBE_CONTEXT=<name>        required: kube context of the Rancher (local) cluster
#   DRY_RUN=1                  run the checks and print the helm command, change nothing
#   RANCHER_FRESH_INSTALL=yes  allow installing where no Rancher release exists
#                              (new cluster, or a rebuild after restoring a backup)
#
# Before an upgrade, run it with DRY_RUN=1 and check the context, versions and Fleet pin it prints.

set -euo pipefail

version_file=./rancher-version
values_file=./values.yaml

fail() {
  echo "Refusing: $*" >&2
  exit 1
}

[[ -f $version_file && -f $values_file ]] ||
  fail "run this from rke2/rancher.<site>/rancher/ (needs $version_file and $values_file)."

context=${KUBE_CONTEXT:-}
[[ -n $context ]] || fail "set KUBE_CONTEXT to the kube context of this site's Rancher (local) cluster."

version=$(tr -d '[:space:]' < "$version_file")
[[ $version =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "'$version' in $version_file is not a version like v2.14.3."

hostname=$(sed -n 's/^hostname:[[:space:]]*//p' "$values_file" | tr -d "\"' ")
[[ -n $hostname ]] || fail "no 'hostname:' in $values_file."

# A Fleet pin must belong to this Rancher minor (Fleet chart major = Rancher minor + 95, e.g. 2.14 -> 109).
# A pin left over from an older version would silently stop Rancher from upgrading Fleet.
fleet_pin=$(awk '/name:[[:space:]]*CATTLE_FLEET_MIN_VERSION/ {getline; sub(/.*value:[[:space:]]*/, ""); print; exit}' "$values_file" | tr -d "\"' ")
if [[ -n $fleet_pin ]]; then
  minor=$(cut -d. -f2 <<< "${version#v}")
  [[ ${fleet_pin%%.*} == $((minor + 95)) ]] ||
    fail "CATTLE_FLEET_MIN_VERSION $fleet_pin in $values_file does not belong to Rancher $version; update or remove it."
fi

if status=$(helm status rancher --kube-context "$context" --namespace cattle-system 2>&1); then
  live_host=$(helm get values rancher --kube-context "$context" --namespace cattle-system |
    sed -n 's/^hostname:[[:space:]]*//p' | tr -d "\"' ")
  [[ $live_host == "$hostname" ]] ||
    fail "context '$context' runs Rancher for '$live_host', but $values_file is for '$hostname'."
  action=upgrade
  current=$(kubectl --context "$context" --namespace cattle-system get deploy rancher \
    -o jsonpath='{.spec.template.spec.containers[0].image}')
elif grep -q 'release: not found' <<< "$status"; then
  [[ ${RANCHER_FRESH_INSTALL:-} == yes ]] ||
    fail "no Rancher release in context '$context'. For a new install or a rebuild, set RANCHER_FRESH_INSTALL=yes."
  action=install
  current=none
else
  echo "$status" >&2
  fail "could not check the Rancher release in context '$context' (see the error above)."
fi

echo "Context: $context"
echo "Rancher: $hostname"
echo "Current: $current"
echo "Target:  rancher-latest/rancher $version ($action)"
[[ -z $fleet_pin ]] || echo "Fleet:   pinned to $fleet_pin"

cmd=(helm upgrade --install rancher rancher-latest/rancher
  --kube-context "$context"
  --namespace cattle-system --create-namespace
  --version "${version#v}"
  --values "$values_file")

if [[ ${DRY_RUN:-} == 1 ]]; then
  printf 'DRY_RUN, would run:'
  printf ' %q' "${cmd[@]}"
  printf '\n'
  exit 0
fi

set -x
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update rancher-latest
"${cmd[@]}"
kubectl --context "$context" --namespace cattle-system rollout status deploy/rancher --timeout=30m
