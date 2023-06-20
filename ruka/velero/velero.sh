#!/bin/env bash

set -ex

#confirm these variables before installing
NAMESPACE='velero'
BUCKET='it-backup-test'
BKP_NAME='default'
VOL_NAME='default'
PREFIX='ruka'
S3Url='https://it-s3.ls.lsst.org'
RGW_SECRET='it-s3-credentials'
REGION='default'

echo -e "\nPlease review these values before installing velero"
echo "namespace: $NAMESPACE"
echo "prefix: $PREFIX"
echo "bucket: $BUCKET"
echo "S3 Url: $S3Url"
while true; do
    read -p "Are these values correct? (Y/N): " input
    if [ "$input" = "N" ] || [ "$input" = "n" ]; then
        echo "Installation stopped."
        exit 0
    elif [ "$input" = "Y" ] || [ "$input" = "y" ]; then
        break
    else
        echo "Invalid input. Please enter Y or N."
    fi
done

# Rest of the script continues here...
echo -e "Continuing with the installation.\n"

#make sure the S3 credentials are setup as env. variable
if [[ -v IT_S3_ACCESSKEY && -v IT_S3_SECRET ]]; then
    echo "AccessKey and Secret key exist, carry on..."
else
    echo "Either IT_S3_ACCESSKEY or IT_S3_SECRET (or both) do not exist"
    exit 1
fi

#add repo
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts

#create namespace if it doesn't exist
kubectl create namespace ${NAMESPACE} || true

#add secret
cat << END | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${RGW_SECRET} 
  namespace: ${NAMESPACE}
  labels:
    app.kubernetes.io/name: velero
    app.kubernetes.io/managed-by: Helm
type: Opaque
stringData:
  cloud: |
    [default]
    aws_access_key_id=${IT_S3_ACCESSKEY}
    aws_secret_access_key=${IT_S3_SECRET}
END

#deploy velero
helm install velero vmware-tanzu/velero \
--namespace ${NAMESPACE} \
--set credentials.useSecret=true \
--set credentials.existingSecret=${RGW_SECRET} \
--set snapshotsEnabled=true \
--set uploaderType=restic \
--set deployNodeAgent=true \
--set configuration.backupStorageLocation[0].name=${BKP_NAME} \
--set configuration.backupStorageLocation[0].provider=aws \
--set configuration.backupStorageLocation[0].bucket=${BUCKET} \
--set configuration.backupStorageLocation[0].prefix=${PREFIX} \
--set configuration.backupStorageLocation[0].config.region=${REGION} \
--set configuration.backupStorageLocation[0].config.s3Url=${S3Url} \
--set configuration.backupStorageLocation[0].config.s3ForcePathStyle=true \
--set configuration.volumeSnapshotLocation[0].name=${VOL_NAME} \
--set configuration.volumeSnapshotLocation[0].provider=aws \
--set configuration.volumeSnapshotLocation[0].config.region=${REGION} \
--set initContainers[0].name=velero-plugin-for-aws \
--set initContainers[0].image=velero/velero-plugin-for-aws:v1.7.0 \
--set initContainers[0].volumeMounts[0].mountPath=/target \
--set initContainers[0].volumeMounts[0].name=plugins


#notes
ns_pvc=`kubectl get pvc --all-namespaces --no-headers -o custom-columns=":metadata.namespace" | sort -u`

echo -e "\nThe following namespaces have PVCs configured, consider them for a backup job" 

echo $ns_pvc | tr '  ' '\n'

formatted_ns_pvc=$(printf "%s," $ns_pvc)
formatted_ns_pvc=${formatted_ns_pvc%,} 

echo -e "\n---Examples:\n"

echo -e "Create a daily backup of all those namespaces every 4 hours and retained for 10 days "
echo -e 'velero schedule create daily --include-namespaces $formatted_ns_pvc  --default-volumes-to-restic --schedule="@every 4h" --ttl 240h0m0s'
echo -e "\nOr Create single backups every 24h and retained for 15 days"

for var in $ns_pvc; do
    echo "velero schedule create daily-$var --include-namespaces $var  --default-volumes-to-restic --schedule=\"@every 24h\" --ttl 360h0m0s"
done
