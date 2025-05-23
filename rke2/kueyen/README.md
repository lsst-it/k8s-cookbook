# Kueyen cluster deployment

```bash
ssh kueyen01.ls.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/kueyen/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/kueyen/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd ingress; ./nginx-ingress-helm.sh)

(cd multus; ./multus.sh)

(cd rook-ceph; ./rook-ceph.sh)
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

MUST BACKUP SECTION FIRST!
(cd velero; ./velero.sh)
```

## Backups

In order to run the velero script, the secret file must be created first:

```bash
cat >resources/secret.yaml <<END
---
apiVersion: v1
kind: Secret
metadata:
  name: aws-credentials
  namespace: velero
  labels:
    app.kubernetes.io/name: velero
    app.kubernetes.io/instance: release-name
type: Opaque
stringData:
  cloud: |
    [default]
    aws_access_key_id=<ACCESS_KEY>
    aws_secret_access_key=<SECRET_KEY>
END
```

```bash
velero schedule create daily --schedule="@every 24h" --ttl 336h0m0s
```

Import andes cluster into rancher via this url:

https://rancher.cp.lsst.org/g/clusters/add/launch/import
