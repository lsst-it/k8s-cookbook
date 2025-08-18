{{- define "alloy.commonLogs" -}}        
    logging {
        level  =  "{{ default "info" (get (default (dict) .ClusterLabels) "log_level") }}"
        format = "logfmt"
      }

      local.file_match "node_logs" {
        path_targets = [{
            __path__  = "/var/log/*.log",
            job       = "node/syslog",
            node_name = sys.env("HOSTNAME"),
            cluster   = "${ get .ClusterLabels "management.cattle.io/cluster-display-name" }",
        }]
      }

      loki.source.file "node_logs" {
        targets    = local.file_match.node_logs.targets
        forward_to = [loki.write.send.receiver]
      }

      discovery.kubernetes "pod" {
        role = "pod"
      }

      discovery.relabel "pod_logs" {
        targets = discovery.kubernetes.pod.targets

        rule {
          source_labels = ["__meta_kubernetes_namespace"]
          action = "replace"
          target_label = "namespace"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_name"]
          action = "replace"
          target_label = "pod"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_container_name"]
          action = "replace"
          target_label = "container"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_label_app_kubernetes_io_name"]
          action = "replace"
          target_label = "app"
        }

        rule {
          source_labels = ["__meta_kubernetes_namespace", "__meta_kubernetes_pod_container_name"]
          action = "replace"
          target_label = "job"
          separator = "/"
          replacement = "$1"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_uid", "__meta_kubernetes_pod_container_name"]
          action = "replace"
          target_label = "__path__"
          separator = "/"
          replacement = "/var/log/pods/*$1/*.log"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_container_id"]
          action = "replace"
          target_label = "container_runtime"
          regex = "^(\\S+):\\/\\/.+$"
          replacement = "$1"
        }
      }

      loki.source.kubernetes "pod_logs" {
        targets    = discovery.relabel.pod_logs.output
        forward_to = [loki.process.pod_logs.receiver]
      }

      loki.process "pod_logs" {
        stage.static_labels {
          values = {
            cluster = "${ get .ClusterLabels "management.cattle.io/cluster-display-name" }",
            job = "k8s/logs",
          }
        }
        forward_to = [loki.write.send.receiver]
      }

      loki.source.kubernetes_events "cluster_events" {
        job_name   = "k8s/events"
        log_format = "logfmt"
        forward_to = [
          loki.process.cluster_events.receiver,
        ]
      }

      loki.process "cluster_events" {
        forward_to = [loki.write.send.receiver]
        stage.regex {
          expression = ".*name=(?P<name>[^ ]+).*kind=(?P<kind>[^ ]+).*objectAPIversion=(?P<apiVersion>[^ ]+).*type=(?P<type>[^ ]+).*"
        }
        stage.labels {
          values = {
            kubernetes_cluster_events = "job",
            name                      = "name",
            kind                      = "kind",
            apiVersion                = "apiVersion",
            type                      = "type",
          }
        }
      }
{{- end }}
