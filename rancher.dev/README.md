# Rancher DEV cluster deployment

```bash
ssh rancher01.dev.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/rancher.dev/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/rancher.dev/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd cert-manager; ./cert-manager.sh)

(cd ingress; ./ingress-nginx.sh)

(cd rancher; ./rancher.sh)
