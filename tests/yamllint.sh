#!/usr/bin/env bash

set -e
shopt -s globstar nullglob

CHECK=( **/*.{yaml,yml,.eyaml} .*.{yml,yaml} )
EYAML=( **/*.eyaml )
IGNORE=()
CONF_FILE=".yamllint.yaml"

# filter out plain text versions of .eyaml files
for e in "${!EYAML[@]}"; do
  uneyaml=${EYAML[e]/eyaml/yaml}
  for c in "${!CHECK[@]}"; do
    [[ ${CHECK[c]} == "$uneyaml" ]] && unset -v 'CHECK[c]'
  done
done

for c in "${!CHECK[@]}"; do
  for i in "${IGNORE[@]}"; do
    [[ ${CHECK[c]} == "$i" ]] && unset -v 'CHECK[c]'
  done
done
[[ ${#CHECK[@]} -eq 0 ]] && { echo 'no files to check'; exit 0; }

echo '---'
echo 'check:'
for c in "${CHECK[@]}"; do
  echo "  - ${c}"
done
echo

ARGS=()
[[ -f $CONF_FILE ]] && ARGS+=(-c "$CONF_FILE")
ARGS+=("${CHECK[@]}")
docker run -ti -v "$(pwd):/workdir" lsstsqre/yamllint:1.16.0 "${ARGS[@]}"

# vim: tabstop=2 shiftwidth=2 expandtab
