Velero installation
====================

Execute and follow the prompts:

./velero.sh

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
