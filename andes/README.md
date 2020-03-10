andes cluster deployment
========================

```bash
ssh andes01.cp.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/andes/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/andes/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd ingress; ./nginx-ingress-helm.sh)

(cd multus; ./multus.sh)

(cd rook-ceph; ./rook-ceph.sh)
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

```

import andes cluster into rancher via this url:

https://rancher.cp.lsst.org/g/clusters/add/launch/import
