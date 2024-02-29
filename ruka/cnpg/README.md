# CloudNativePG cluster deployment

The cloudnativePG is a K8s Operator for PostgreSQL
this deployment is cluster database with the following features:

- PGsphere extension 1.2.0 included in custom image with postgreSQL 14.5
- 3 POD cluster
- 3 read/write services (rw service is exposed)
- S3 AWS backup capabilities (multiple instances can use same the bucket but different path folders)
- Backups are gziped for storage optimization
- 60 Days backup retention policy
- 5Gi initial storage dedicated PVCs (can be resized)
- dB monitoring stats ready in Prometheus format with PodMonitor (```curl http://<pod_ip>:9187/metrics```)

## Instructions

- RUN deployment script

   ```bash
   ./cnpg.sh
   ```

- Following command will provide the external ip for the service.

   ```bash
   kubectl -n cloudnativepg get services
   ```

- Test connectivity providing information on the following command line:

   ```bash
   PGPASSWORD='"insert superuser password"' psql -h ("ip of the service") -U postgres
   ```

   *DNS needs to be setup for this, use the external IP address.*

## Recovery from Backup

To restore the database, the cluster needs to be started in recovery mode.

There is a yaml file provided for restoring the database from the S3
(new empty folder needs to be provided to avoid overwrite on previous backups)

fill the correct information inside the file ```cnpg-recovery.yaml``` (buckets directory)
replace ```kubectl apply -f deploy.yaml``` for ```kubectl apply -f cnpg-recovery.yaml```
inside ```cnpg.sh``` and then execute the script to start the cluster in recovery mode with previous backup.
