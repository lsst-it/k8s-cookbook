Velero installation
====================

Before you begin, make sure the variables inside the script are correct and set your S3 credentials to the following env. variables:

export IT_S3_ACCESSKEY=XXXXXXX
export IT_S3_SECRET=YYYYYY

Execute ./velero.sh and follow the prompts.

Create backup for single namespace:
velero backup create test-backup --include-namespaces namespace1 --default-volumes-to-restic

Create backup for multiple namespaces:
velero backup create test-backup --include-namespaces namespace1,namespace2 --default-volumes-to-restic

Restore backup:
velero restore create --from-backup test-backup

Restore backup of a single namespace:
velero restore create --from-backup nginx-backup --include-namespaces namespace1

Restore backup of a single namespace to a different namespace
velero restore create --from-backup test-backup --include-namespaces namespace1 --namespace-mappings namespace1:namespace1-new
