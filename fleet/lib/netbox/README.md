# NetBox Kubernetes Deployment

## Overview

NetBox is an Infrastructure Resource Modeling (IRM) application designed to empower network automation. This deployment provides a production-ready NetBox instance on Kubernetes using Helm charts and Fleet configuration management.

## Architecture

- **Chart**: netbox v6.1.5 from <https://charts.netbox.oss.netboxlabs.com/>
- **Namespace**: netbox
- **Components**: Web application, worker processes, PostgreSQL database, Valkey cache
- **Ingress**: NGINX with Let's Encrypt TLS certificates

## Configuration

### Core Settings

- **Timezone**: America/Santiago
- **Superuser**: <admin@lsst.org>
- **Change Log Retention**: 90 days
- **Job Retention**: 90 days
- **GraphQL**: Enabled
- **Login Required**: False

### Security

- Non-root container execution (UID/GID: 1000)
- Read-only root filesystem
- Dropped capabilities
- Runtime security profile enabled
- External secret management via Kubernetes secrets

### Storage

- **Persistence**: Disabled (ephemeral storage)
- **PostgreSQL**: 20Gi persistent storage (rook-ceph-block)
- **Media/Reports/Scripts**: Stored in ephemeral volumes

### Resources

| Component | CPU Request | Memory Request | CPU Limit | Memory Limit |
|-----------|-------------|----------------|-----------|--------------|
| NetBox    | 500m        | 1Gi            | 1000m     | 2Gi          |
| Worker    | 500m        | 1Gi            | 1000m     | 2Gi          |
| PostgreSQL| 250m        | 512Mi          | 500m      | 1Gi          |

## Access

NetBox is accessible via dynamically generated hostnames based on cluster configuration:

```bash
https://netbox.{cluster-name}.{site}.lsst.org
```

## Maintenance

- **Housekeeping**: Daily automated cleanup (00:00 UTC)
- **Job History**: 5 successful/failed jobs retained
- **Monitoring**: Available via cluster monitoring stack
