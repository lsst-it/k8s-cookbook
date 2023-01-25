# CloudNativePG cluster deployment

The cloudnativePG is a K8s Operator for PostgreSQL
this deployment is cluster database with the following features:

- 3 POD cluster
- 3 read/write services (rw service is exposed)
- S3 AWS backup capabilities (multiple instances can use same the bucket but different path folders)
- Backups are gziped for storage optimization
- 90 Days backup retention policy
- 10Gi initial storage dedicated PVCs (can be resized)
- dB monitoring stats ready in Prometheus format (```curl http://<pod_ip>:9187/metrics```)

## Instructions

- Set enviroment variables for secrets creation.

   ```bash
   export USER_PASSWORD=("password for app user")
   export SUPERUSER_PASSWORD=("password for postgre user")
   export AWS_ACCESS_KEY_ID=("insert access key here")
   export AWS_ACCESS_SECRET_KEY=("insert access secret key here")
   export AWS_ACCESS_BUCKET=("s3:// insert bucket folder address")
   ```

- RUN deployment script

   ```bash
   ./cnpg.sh
   ```

- Following command will provide the external ip for the service.

   ```bash
   kubectl -n cloudnativepg get services
   ```

- Test connectivity providing information on the following command line:

   export PGPASSWORD=$SUPERUSER_PASSWORD

   ```psql -h ("ip of the service") -U postgres
   ```

   *DNS needs to be setup for this, use the external IP address.*
   *psql binary must exist in your local computer*

## Backup installation (temporary)

- RUN

 ```bash
   ./cnpg-backup.sh
   ```
