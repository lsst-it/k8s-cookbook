# 🔍 Understanding Loki + Fluent Bit + Rook-Ceph + Mimir + Grafana

This README provides a **high-level and technically accurate overview** of how Grafana Loki is deployed and integrated in a modern observability stack. It focuses not just on YAML and Helm, but on **how components talk to each other**, and how you can extend observability across systems like **pfSense**, **network appliances**, **rsyslog**, and **Grafana Mimir**.

---

## 📦 What is Loki

Grafana Loki is a **horizontally scalable, highly available log aggregation system** inspired by Prometheus.

- It stores logs as **compressed, indexed chunks** in object storage.
- It supports multi-tenant logs via labels (`{app="nginx"}`).
- Loki is **queryable via LogQL**, a Prometheus-like language.

---

## 🌀 Fluent Bit Integration

Fluent Bit is a **lightweight log forwarder** used to send logs to Loki.

### 💡 Integration Flow

```bash
[ log source ] --> [ Fluent Bit ] --> [ Loki Distributor ] --> [ Rook-Ceph S3 ]
```

### 📂 Use Cases with Fluent Bit External

- **pfSense**: Using syslog-over-UDP to forward firewall and system logs to Fluent Bit
- **Networking Devices**: Routers/switches sending syslog to Fluent Bit for routing into Loki
- **rsyslog**: Local system logs sent via TCP/UDP to Fluent Bit
- **Container Logs**: Automatically captured using Kubernetes plugins

### 📦 Fluent Bit Output Example

```ini
[OUTPUT]
 Name          loki
 Match         *
 Host          loki-gateway.loki.svc.cluster.local
 Port          3100
 Labels        job=fluentbit,host=$HOSTNAME
 Auto_Kubernetes_Labels On
```

---

## 🏗 How Loki Stores Logs (Rook-Ceph)

Loki in distributed mode uses **Rook-Ceph (S3 Gateway)** as its object store.

- All log chunks are stored in buckets: `logs-chunks`, `logs-ruler`, `logs-admin`
- Access keys are created via `CephObjectStoreUser`
- Loki reads/writes chunks using the S3-compatible API

### 🎯 Why Rook-Ceph

- Runs inside Kubernetes
- Provides internal S3-like storage
- Cost-effective for on-prem clusters

---

## 📊 How Loki Works With Mimir

Mimir is used for **metrics**, while Loki is used for **logs**.

Together, they power **correlated observability**:

| Mimir                        | Loki                             |
|-----------------------------|----------------------------------|
| Time-series metrics         | Structured logs                  |
| Query via PromQL            | Query via LogQL                  |
| Store in local storage (e.g., TSDB (e.g., Ceph) | Store in S3 buckets           |

Grafana supports **LogQL links from metrics to logs** (e.g., clicking on a CPU alert displays container logs from that moment).

---

## 🎨 How Grafana Connects Everything

Grafana is your **single pane of glass** for:

- **Metrics** from Prometheus/Mimir
- **Logs** from Loki
- **Alerts** from Alertmanager
- **Dashboards** with multi-source panels

### ✅ Grafana Data Sources

- Loki (logs):

  ```bash
  URL: http://loki-gateway.loki
  ```

- Mimir (metrics):

  ```bash
  URL: http://mimir-distributed-gateway.mimir:80/prometheus
  ```

- Alerting and annotations:
 Native via Grafana Alerting and Loki alert rules

---

## 🔄 End-to-End Example: pfSense → Grafana

- pfSense sends logs via syslog to Fluent Bit External(UDP).
- Fluent Bit parses and forwards to Loki via HTTP.
- Loki stores log chunks in Rook-Ceph buckets.
- Grafana reads from Loki to show pfSense logs on dashboards.
- Mimir collects metrics from other exporters (e.g., node_exporter).
- Grafana allows users to **correlate logs and metrics** on the same dashboard.

---

## 🧪 Bonus: Best Practices

- Use labels consistently in Fluent Bit to make logs queryable (`job`, `host`, `source`)
- Configure log retention in Loki via compactor (`retention_enabled: true`)
- Use Rook-Ceph lifecycle policies to clean old log chunks
- Link alerts from Mimir directly to logs in Loki

---

## 📚 References

- [Grafana Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Fluent Bit Documentation](https://docs.fluentbit.io/)
- [Rook Documentation](https://rook.io/docs/)
- [Grafana Mimir Documentation](https://grafana.com/docs/mimir/)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
