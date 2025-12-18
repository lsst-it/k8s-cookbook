# Prometheus rules GitOps

Any Prometheus rules file defined in the `/rules` directory will be deployed to
the cluster. It's possible to define a default namespace in the `values.yaml`
file with the `rules.namespace` key.

## Adding Prometheus rules

1. Write the Prometheus rules in a yaml file according to the [prometheus
   specification](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/).
1. Add the YAML file to the `/rules` directory
1. Commit

## Prometheus rule DevOps Rubin standards

* `summary` annotation: This annotation MAY contain a templated variable to differentiate between hosts, pods, clusters, etc. and provides a simple single sentence summary of what the alert is about. For example, "Disk space full in acme.lsst.org". When a cluster triggers several alerts, it can be helpful to group these alerts into a single notification. A distinctive summary, it is also useful as a title for Jira tickets.
* `description` annotation: This provides a detailed overview of the alert specifically to this instance of the alert. It MAY contain templated variables to enrich the message.
* routing label: Rubin uses labels to route alerts. The label is used by alertmanager to determine the routing of the notification for the alert. By default, all alerts should be routed to Squadcast. The escalation and notification will be handled by Squadcast API.

  Currently (20250904) the following receivers are configured:
* `gnocpush`: Requires label `gnoc: "true"`
* `squadcast-alertmanager`: Requires label `prod: "true"`. In most cases this should be the label of the alert.
* `squadcast-alertmanager-oncall`: Requires label `oncall: "true"`. It will trigger the Run Support escalation. Use with caution.
