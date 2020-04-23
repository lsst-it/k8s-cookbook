rook-ceph
=========

how to access ceph toolbox pod
---

```bash
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash
```

useful toolbox commands:

* `ceph status`
* `ceph osd status`

simple test deployment to verify that ceph backed PVs can be created
---

```bash
kubectl apply -f ceph-pvc-demo.yaml
```

complete ceph cluster tear down (will loose all data)
---

Run from rke user env:

_Must be run prior to the node cleanup._

```bash
./rook-ceph-k8s-cleanup.sh
```

Run from workstation with personal ssh-agent setup:

```bash
./rook-ceph-node-cleanup.sh
```
