rancher cluster deployment
==========================

```bash
ssh rancher1.ls.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/rancher.ls/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/rancher.ls/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd cert-manager; ./cm-and-clusterissuer.sh)

(cd ingress; ./ingress-nginx-helm.sh)

(cd rancher; ./rancher.sh)
```
