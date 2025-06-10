# Rancher Backup and Restore

## Prerequisites

Before restoring a Rancher backup, you must install the following dependencies:

- MetalLB
- Ingress Controller (e.g., NGINX)
- cert-manager
- 1Password/OpenConnect integration (for secrets)
- External Secrets

Do **not** install Rancher yet.

## Steps

- **Install dependencies** listed above.
- Run the script:

   ```bash
   ./rancher-backup.sh
   ```

   This will:
   - Install the required Kubernetes secret
   - Apply the Backup and Restore CRDs
   - Deploy the rancher-backup Helm chart

- Edit the Restore CRD:
   - Replace the backup filename with the one from your AWS bucket that matches the appropriate site backup.

## Important

**Do not install Rancher** before restoring the backup. FIRST restore, then install Rancher.

More information:
https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/backup-restore-and-disaster-recovery/migrate-rancher-to-new-cluster
