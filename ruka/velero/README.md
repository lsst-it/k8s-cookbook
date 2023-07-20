Velero installation
====================

Before you begin, make sure the variables inside the script are correct and set your S3 credentials to the following env. variables:

Local S3
export IT_S3_ACCESSKEY=XXXXXXX
export IT_S3_SECRET=YYYYYY

AWS S3
export AWS_BKP_ACCESSKEY=XXXXXXX
export AWS_BKP_SECRET=YYYYYY

Execute and follow the prompts:
 ./velero-local.sh <- for local S3 Installations.
 ./velero-aws.sh <- for AWS S3 Installations.

Create backup for single namespace:
velero backup create test-backup --include-namespaces namespace1 --default-volumes-to-fs-backup

Create backup for multiple namespaces:
velero backup create test-backup --include-namespaces namespace1,namespace2 --default-volumes-to-fs-backup

Restore backup:
velero restore create --from-backup test-backup

Restore backup of a single namespace:
velero restore create --from-backup nginx-backup --include-namespaces namespace1

Restore backup of a single namespace to a different namespace
velero restore create --from-backup test-backup --include-namespaces namespace1 --namespace-mappings namespace1:namespace1-new

To enable listing CSI details in the describe command:
velero client config set features=EnableCSI
