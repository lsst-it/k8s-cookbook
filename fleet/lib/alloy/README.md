# Alloy

Alloy has a dual purpose, to send and receive logs. As a client it will send the following:

- Nodes logs
- Kubernetes logs
- Kubernetes events

As a server will receive:

- Nodes logs
- Kubernetes logs
- Kubernetes events
- Firewall logs
- Network logs

The severity of the logs is configured as default as "info", to change it add the label `` log_level `` to the cluster with the desired severity. It could be

- `` debug ``
- `` info ``
- `` warn ``
- `` error ``

Happy logging