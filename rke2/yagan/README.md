# Yagan cluster deployment

```bash
ssh yagan01.cp.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/yagan/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/yagan/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd cert-manager; ./cert-manager.sh)

(cd ingress; ./ingress-nginx-helm.sh)

(cd multus; ./multus.sh)
```

Import yagan cluster into rancher via this url:

https://rancher.cp.lsst.org/g/clusters/add/launch/import?importProvider=other
