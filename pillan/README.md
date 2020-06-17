pillan cluster deployment
=========================

```bash
ssh pillan01.ls.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/pillan/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/pillan/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd ingress; ./nginx-ingress-helm.sh)

(cd multus; ./multus.sh)

#Must first create secret.yaml and letsencrypt.yaml
(cd cert-manager; ./cert-manager.sh)

(cd rook-ceph; ./rook-ceph.sh)
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

```

import pillan cluster into rancher via this url:

https://rancher.tu.lsst.org/g/clusters/add/launch/import
