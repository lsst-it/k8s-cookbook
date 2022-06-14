# Chonchon cluster deployment

```bash
ssh chonchon01.cp.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/chonchon/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/chonchon/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd ingress; ./ingress-nginx-helm.sh)

(cd cert-manager; ./cm-and_clusterissuer.sh)

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

Import chonchon cluster into rancher via this url:

https://rancher.cp.lsst.org/g/clusters/add/launch/import
