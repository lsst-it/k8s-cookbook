vk8s cluster deployment
========================

```bash
ssh vk8s01.ls.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/vk8s/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/vk8s/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd cert-manager; ./cm-and-clusterissuer.sh)

(cd ingress; ./nginx-ingress-helm.sh)

(cd rook-ceph; ./rook-ceph.sh)
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

import andes cluster into rancher via this url:

https://rancher.cp.lsst.org/g/clusters/add/launch/import
