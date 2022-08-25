# CloudNativePG cluster deployment

The cloudnativePG is a K8s Operator for PostgreSQL
this deployment is cluster database with the following features:

- 3 POD cluster
- 3 read/write services (rw service is exposed)
- S3 AWS backup capabilities
- Backups are gziped for storage optimization
- 90 Days backup retention policy
- 10Gi initial storage dedicated PVCs (can be resized)
- dB monitoring stats ready in Prometheus format (```curl http://<pod_ip>:9187/metrics```)

# Instructions

1. Set enviroment variables for secrets creation.
   ```bash
   export USER_PASSWORD=(password for app user)
   export SUPERUSER_PASSWORD=(password for postgre use)
   export AWS_ACCESS_KEY_ID=(insert access key here)
   export AWS_ACCESS_SECRET_KEY=(insert access secret key here)
   export AWS_ACCESS_BUCKET=(s3:// insert bucket folder address)
   ```
2. RUN deployment script
   ```bash
   ./cnpg.sh
   ```

