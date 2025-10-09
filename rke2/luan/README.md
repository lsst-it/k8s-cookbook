# Luan Cluster Deployment

```bash
ssh luan01.ls.lsst.org
sudo -iu rke
git clone https://github.com/lsst-it/k8s-cookbook
cd k8s-cookbook/luan/

(cd rke; rke up)
export KUBECONFIG=/home/rke/k8s-cookbook/luan/rke/kube_config_cluster.yml

(cd metallb; ./metallb.sh)

(cd cert-manager; ./cert-manager.sh)

(cd ingress; ./ingress-nginx-helm.sh)

(cd multus; ./multus.sh)

(cd rook-ceph; ./rook-ceph.sh)
```

Import luan cluster into rancher via this url:
https://rancher.ls.lsst.org/g/clusters/add/launch/import?importProvider=other
