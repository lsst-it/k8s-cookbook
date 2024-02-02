#!/bin/env bash

set -ex

# confirm these variables before installing
NAMESPACE='velero'
VERSION='4.1.0'

# add repo
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update

# create namespace if it doesn't exist
kubectl create namespace ${NAMESPACE} || true

# add secret
kubectl apply -f externalsecret-it-s3-credentials.yaml

# deploy velero
echo "installing velero..(it could take a few mins.)"
helm upgrade --install \
  velero vmware-tanzu/velero \
  --create-namespace --namespace ${NAMESPACE} \
  --version ${VERSION} \
  --atomic \
  -f ./values.yaml \

# notes
ns_pvc=$(kubectl get pvc --all-namespaces --no-headers -o custom-columns=":metadata.namespace" | sort -u)

echo -e "\nThe following namespaces have PVCs configured, consider them for a backup job"

echo "$ns_pvc" | tr '  ' '\n'

formatted_ns_pvc=$(echo "$ns_pvc" | tr '\n' ','| sed 's/,$//')

echo -e "\n---Examples:\n"

echo -e "Create a daily backup of all those namespaces every 4 hours and retained for 10 days "
echo -e "velero schedule create daily --include-namespaces $formatted_ns_pvc  --default-volumes-to-restic --schedule=\"@every 4h\" --ttl 240h0m0s"

echo -e "\nOr Create single backups every 24h and retained for 15 days"

for var in $ns_pvc; do
    echo "velero schedule create daily-$var --include-namespaces $var  --default-volumes-to-restic --schedule=\"@every 24h\" --ttl 360h0m0s"
done
