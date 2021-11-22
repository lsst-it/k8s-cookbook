rook-ceph
=========

how to access ceph toolbox pod
---

```bash
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- bash
```

useful toolbox commands:

* `ceph status`
* `ceph osd status`

simple test deployment to verify that ceph backed PVs can be created
---

```bash
kubectl apply -f ./demo/ceph-demo-pvc.yaml
```

complete ceph cluster tear down (will loose all data)
---

Run from rke user env:

_Must be run prior to the node cleanup._

```bash
./scripts/rook-ceph-k8s-cleanup.sh
```

Run from workstation with personal ssh-agent setup:

```bash
./scripts/rook-ceph-node-cleanup.sh
```

NFS Exports
-----------

https://rook-ceph.tu.lsst.org/#/nfs/create

Create in order:

- jhome
- lsstdata
- project
- scratch

```
"Create NFS export"

Cluster: lsstdata
Daemons: nfs.lsstdata
Storage Backend: CephFS
CephFS User ID: admin
CephFS Name: lsstdata
Security Label: <unchecked>
CephFS Path: /lsstdata
NFS Protocol:
       NFSv3: <checked>
       NFSv4: <checked>
NFS Tag: lsstdata
Pseudo: /lsstdata
Access Type: RW
Squash: no_root_squash
Transport Protocol:
       UDP: <checked>
       TCP: <checked>
Clients: <Any client can access>
```
