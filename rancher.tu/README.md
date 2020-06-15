rancher cluster deployment
==========================

```bash
ssh rancher1.tuc.lsst.cloud
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/rancher.tu/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/rancher.tu/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd cert-manager; ./cert-manager.sh)

(cd ingress; ./nginx-ingress-helm.sh)

(cd rancher; ./rancher.sh)
```
