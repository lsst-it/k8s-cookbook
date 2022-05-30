ruka cluster deployment
=========================

ssh ruka01.dev.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/ruka/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/ruka/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd cert-manager; ./cert-manager.sh)

(cd ingress; ./ingress-nginx-helm.sh)

(cd multus; ./multus.sh)

(cd rook-ceph; ./rook-ceph.sh)

READ BACKUP SECTION BEFORE RUNNING!
(cd velero; ./velero.sh)
```

Backups
-------
In order to run the velero script, the secret file must be created first:

```yaml
---
# Source: velero/templates/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: release-name-velero
  namespace: velero
  labels:
    app.kubernetes.io/name: velero
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/managed-by: Helm
    helm.sh/chart: velero-2.29.7
type: Opaque
data:
  base: <Insert AWS Secret>
```

import ruka cluster into rancher via this url:

https://rancher.ls.lsst.org/g/clusters/add/launch/import?importProvider=other
