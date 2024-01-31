# CloudNativePG cluster REPLICA deployment

The cloudnativePG is a K8s Operator for PostgreSQL
this deployment is cluster is meant to be use as replica from another cluster.

There's still some thing to get ready before deploying

Most probably you will need credentials which are in the vault.

Adjust credentials and settings for the cluster to be replicated and then run the script:

- Replication postgres config on server needs following:

  ```bash
  pg_hba:
    - host replication postgres all md5
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

   ```bash
   PGPASSWORD='"insert superuser password"' psql -h ("ip of the service") -U postgres
   ```

   *DNS needs to be setup for this, use the external IP address.*
