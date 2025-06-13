# 🔄 K8up Backup with Rancher Fleet

This repository configures [K8up](https://k8up.io/) via Rancher Fleet to automate persistent volume backups in Kubernetes using restic and an external S3-compatible object store.

---

## 📦 Repository Structure

| Path | Purpose |
|------|---------|
| `k8up-crds/`   | Deploys K8up CustomResourceDefinitions (CRDs) |
| `k8up-pre/`    | Creates `ClusterExternalSecret` to sync S3 credentials into backup-enabled namespaces |
| `k8up/`        | Installs the K8up Helm chart and configures the backup environment (S3 endpoint, restic password, etc.) |
| `k8up-post/`   | Applies `Schedule` resources to trigger automated backups in selected namespaces |

---

## 🚀 How It Works

1. Any namespace labeled `k8up-enabled=true` will:
   - Receive the `k8up-s3-credentials` secret via `ClusterExternalSecret`.
   - Be eligible for backup if its PVCs are annotated.
2. Backup schedules (defined in `k8up-post/`) trigger periodic restic jobs that back up PVC contents to the configured S3 bucket.

---

## 🧪 Sample Output: Querying Backups and Snapshots

### 🔍 View current backups (Example)

```bash
kubectl get backup

NAME                         SCHEDULE REF    COMPLETION   PREBACKUP              AGE
demo-backup                                  Succeeded    NoPreBackupPodsFound   3m20s
schedule-test-backup-b6bxz   schedule-test                NoPreBackupPodsFound   20s
schedule-test-backup-sj5rt   schedule-test                NoPreBackupPodsFound   80s
schedule-test-backup-whnkl   schedule-test   Failed       NoPreBackupPodsFound   2m20s

```

### 🔍 View available snapshots (Example)

```bash
kubectl get snapshots.k8up.io -n nexus

NAME       DATE TAKEN             PATHS                       REPOSITORY
00dcfddc   2025-07-09T16:41:08Z   /data/data-nexus-nexus3-0   s3:s3.gaw.ls.lsst.org/ruka-k8up
0292e48c   2025-07-09T16:37:30Z   /data/data-nexus-nexus3-0   s3:s3.gaw.ls.lsst.org/ruka-k8up
0369a833   2025-07-09T16:41:14Z   /data/data-nexus-nexus3-0   s3:s3.gaw.ls.lsst.org/ruka-k8up
05869032   2025-07-09T16:32:54Z   /data/data-nexus-nexus3-0   s3:s3.gaw.ls.lsst.org/ruka-k8up
0644f76f   2025-07-09T16:31:58Z   /data/data-nexus-nexus3-0   s3:s3.gaw.ls.lsst.org/ruka-k8up

```

## 🧪 Sample Output: Restore a backup.

### 🔍 Restore a PVC in a Namespace (Example)

```yaml

Create new pvc first

---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: restore-test-pvc
  namespace: k8up
  annotations:
    k8up.io/backup: "false"
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
---
Create restore job, to dump the lastest backup to that pvc

apiVersion: k8up.io/v1
kind: Restore
metadata:
  name: restore-testv2
  namespace: k8up
spec:
  restoreMethod:
    folder:
      claimName: restore-test-pvc
  backend:
    repoPasswordSecretRef:
      name: k8up-s3-credentials
      key: restic_password
    s3:
      endpoint: s3.ruka.dev.lsst.org
      bucket: rubinobs-k8up-dev
      accessKeyIDSecretRef:
        name: k8up-s3-credentials
        key: access-key-id
      secretAccessKeySecretRef:
        name: k8up-s3-credentials
        key: secret-access-key

Then bind the pvc to a pod to view its contents
```

> Backups created by K8up are fully compatible with the [Restic CLI documentation](https://docs.k8up.io/k8up/2.12/how-tos/restore.html). You can use the Restic client directly to inspect, restore, or manage snapshots outside of K8up workflows.
