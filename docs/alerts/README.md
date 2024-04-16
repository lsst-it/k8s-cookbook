# Prometheus rules GitOps

Any Prometheus rules file defined in the
[fleet/lib/prometheus-alertrules/rules](../../prometheus-alertrules/rules)
directory will be deployed to the cluster. It's possible to define a default
namespace in the `values.yaml` file with the `rules.namespace` key.

## Adding Prometheus rules

1. Write the Prometheus rules in a yaml file according to the [prometheus
   specification](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/).
1. Add the YAML file to the `/rules` directory
1. Commit

## Prometheus rule AURA standards

* `summary` annotation: The `summary` annotation is used to be able to describe a
  group of alerts incomming. This annotation DOES NOT contain any templated
  variables and provides a simple single sentence summary of what the alert is
  about. For example "Disk space full in 24h". When a cluster triggers several
  alerts, it can be hany to group these alerts into a single notification, this
  is when the `summary` can be used.
* `discription` annotation: This provides a detailed overview of the alert
  specifically to this instance of the alert. It MAY contain templated variables
  to enrich the message.
* `receiver` label: The receiver label is used by alertmanager to decide on the
  routing of the notification for the alert. It exists out of `,` seperated list
  of receivers, pre- and suffixed with `,` to make regex matching easier in the
  alertmanager. For example: `,slack,squadcast,email,` The receivers are defined
  in the alertmanager configuration.
  Currently (20240503) the following receivers are configured:
  * `slack-test`
  * `squadcast-test`
