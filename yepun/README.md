yepun cluster deployment
=========================

```bash
ssh yepun01.ls.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/yepun/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/yepun/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd cert-manager; ./cert-manager.sh)

(cd ingress; ./ingress-nginx-helm.sh)

(cd multus; ./multus.sh)

(cd rook-ceph; ./rook-ceph.sh)
```

import yepun cluster into rancher via this url:

https://rancher.cp.lsst.org/g/clusters/add/launch/import?importProvider=other
