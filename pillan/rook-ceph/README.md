rook-ceph
=========

update from 1.3.1 to 1.3.4
---

```bash
kubectl -n rook-ceph set image deploy/rook-ceph-operator rook-ceph-operator=rook/ceph:v1.3.4
bash
```

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
./scripts/rook-ceph-k8s-cleanup.sh
```

Run from workstation with personal ssh-agent setup:

```bash
./scripts/rook-ceph-node-cleanup.sh
```
