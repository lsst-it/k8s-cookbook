chonchon cluster deployment
========================

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

```

import chonchon cluster into rancher via this url:

https://rancher.cp.lsst.org/g/clusters/add/launch/import
