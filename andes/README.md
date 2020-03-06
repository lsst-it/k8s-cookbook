andes cluster deployment
========================

```bash
ssh andes01.cp.lsst.org
sudo -iu rke
git clone https://github.com/jhoblitt/k8s-cookbook
cd k8s-cookbook/andes/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/andes/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd ingress; ./nginx-ingress-helm.sh)

(cd multus; ./multus.sh)

(cd rook-ceph; ./rook-ceph.sh)
```

import andes cluster into rancher via this url:

https://rancher.cp.lsst.org/g/clusters/add/launch/import
