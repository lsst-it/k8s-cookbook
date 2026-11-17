# Dev Rancher upgrade: v2.11.0 → v2.14.3 (direct jump)

## Summary

The dev Rancher server (the `local` cluster) runs Rancher v2.11.0 with Fleet 0.12.0. It manages five imported RKE2 clusters. This doc is the runbook to move it to v2.14.3 in one step, with the background further down.

| Item | Value |
|---|---|
| Ticket | IT-7373, branch `IT-7373_rancher_update` |
| Change window | TBD |
| Current Rancher | v2.11.0, HA (3 replicas on a 3-node RKE2 cluster) |
| Target Rancher | v2.14.3 (Fleet 0.15.4, bundled) |
| Local Kubernetes | v1.35.3+rke2r1 |
| Downstream clusters | ayekan, kona, kueyen, pukem, ruka: imported, v1.35.3+rke2r1 |

**Why v2.14.3:** the ticket's v2.11.19 can't be installed (the 2.11.x charts require Kubernetes `< 1.33`, and 2.11.4+ are Prime-only). v2.14.3 is the latest community 2.14 release; its chart allows Kubernetes `< 1.36`, and a server-side dry-run against dev passed. v2.15.3 was looked at and not chosen (appendix). Going straight from 2.11 is outside the official upgrade path; see Background.

**Status (2026-11-17):**

| Phase | State |
|---|---|
| 0 Pre-checks | ✓ Done 2026-11-17 (results under Baselines). Repeat 0.6–0.8 on the day |
| 1 Repo changes | ✓ Done: `rancher.sh` (`308e02bb`), `values.yaml` (`8684583e`) and this doc; not pushed |
| 2–5 Upgrade day | Not started |
| 6 rancher-backup v10 | Not started; at least 24h after the upgrade |

Edits to the repo are allowed; pushes are not.

---

## Before you start

### Tools

| Tool | Required version | Why |
|---|---|---|
| Helm | **3.x, 3.18 or newer**; not Helm 4 | Rancher 2.12+ documents only Helm 3.18+. Helm 4 isn't covered by Rancher's docs and, for example, warns `unable to find exact version requested` for `--version v2.14.3` |
| kubectl | **Within one minor of the clusters' Kubernetes**: 1.34–1.36 for 1.35 | Kubernetes version skew policy |
| curl, jq, ssh, scp | Any recent version | Used by the check and snapshot commands |

Check what you have:

```sh
helm version --short
kubectl version --client
```

If either is outside the range, install matching versions in a separate directory and put it first in `PATH` for the upgrade session only. This works on macOS and Linux, amd64 or arm64. The versions below are examples that meet the requirements:

```sh
HELM_VERSION=v3.19.2       # any 3.x, 3.18 or newer
KUBECTL_VERSION=v1.35.3    # within one minor of the clusters' Kubernetes
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
T=~/bin/rancher-upgrade && mkdir -p "$T"
curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-${OS}-${ARCH}.tar.gz" \
  | tar -xz -C "$T" --strip-components=1 "${OS}-${ARCH}/helm"
curl -fsSLo "$T/kubectl" "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${OS}/${ARCH}/kubectl" && chmod +x "$T/kubectl"
export PATH="$T:$PATH"
helm version --short
kubectl version --client
```

Your usual `helm` and `kubectl` stay untouched. If you use this directory, run the `export PATH` line again in every new terminal.

### Access

| What | How |
|---|---|
| Rancher local cluster | kubeconfig context `local-dev` |
| Downstream clusters, normal | kubeconfig contexts `ayekan`, `kona`, `kueyen`, `pukem`, `ruka`. They go through the Rancher proxy and **stop working if Rancher is down** |
| Downstream clusters, if Rancher is down | from a server node of the cluster (see the team's internal docs) |
| etcd snapshots and restore | on a server node, with root privileges |

The commands use those context names. If yours differ (`kubectl config get-contexts`), adjust them.

The snapshot commands use two variables. Set them from the team's internal node list:

```sh
LOCAL_SERVER=<one server node of the local cluster>
DOWNSTREAM_SERVERS="<one server node per downstream cluster, space-separated>"
```

If `sudo rke2` isn't found, use the full path to the `rke2` binary.

### Working directory

Baselines, backup names and snapshots from the upgrade go here:

```sh
B=~/rancher-2.14.3-upgrade && mkdir -p "$B/etcd"
```

---

## Runbook

### Phase 0: pre-checks (read-only)

All done on 2026-11-17 (results under Baselines). Repeat 0.6, 0.7 and 0.8 on the day.

#### 0.1 No RKE1 left (2.12 removes RKE1; the pre-upgrade hook fails if any exists)

```sh
kubectl --context local-dev get clusters.management.cattle.io \
  -o custom-columns=ID:.metadata.name,NAME:.spec.displayName,DRIVER:.status.driver,PROVIDER:.status.provider
kubectl --context local-dev get nodetemplates.management.cattle.io,clustertemplates.management.cattle.io -A
```

Expected: every cluster `rke2/rke2`, and `No resources found`.

#### 0.2 Imported clusters not affected by #51066

```sh
kubectl --context local-dev get clusters.provisioning.cattle.io -A
kubectl --context local-dev get clusters.management.cattle.io \
  -o custom-columns=NAME:.spec.displayName,AGENT:.spec.desiredAgentImage,AUTH:.spec.desiredAuthImage,REGISTRY:.spec.clusterSecrets.privateRegistryURL
```

Expected: `AGENT`, `AUTH` and `REGISTRY` empty or `<none>` on every cluster.

#### 0.3 No Restricted Admin bindings (removed in 2.12)

```sh
kubectl --context local-dev get globalrolebindings.management.cattle.io \
  -o custom-columns=NAME:.metadata.name,ROLE:.globalRoleName | grep -i restricted
```

Expected: no output.

#### 0.4 Feature flags

```sh
kubectl --context local-dev get features.management.cattle.io
```

Expected: the only custom value is `provisioningv2-fleet-workspace-back-population=true`.

#### 0.5 Disk space for the SQLite UI cache (about 2× the etcd snapshot)

```sh
for c in local-dev ayekan kona kueyen pukem ruka; do
  echo "== $c latest etcd snapshot bytes: $(kubectl --context $c get etcdsnapshotfiles.k3s.cattle.io \
    --sort-by=.status.creationTime -o jsonpath='{.items[-1:].status.size}')"
  for n in $(kubectl --context $c get nodes -o name | cut -d/ -f2); do
    kubectl --context $c get --raw "/api/v1/nodes/$n/proxy/stats/summary" \
      | jq -r --arg n "$n" '"  \($n) free GiB: \(.node.fs.availableBytes / 1073741824 | floor)"'
  done
done
```

Expected: free space well above 2× the snapshot on every node.

#### 0.6 Save the baselines (on the day, just before Phase 2)

```sh
helm --kube-context local-dev ls -A                       > "$B/helm-local-before.txt"
kubectl --context local-dev get clusters.fleet.cattle.io -A > "$B/fleet-clusters-before.txt"
kubectl --context local-dev get gitrepos -A                > "$B/gitrepos-before.txt"
kubectl --context local-dev get bundles -A | awk 'NR==1 || $3!="1/1"' > "$B/bundles-not-ready-before.txt"
for c in ayekan kona kueyen pukem ruka; do
  echo "== $c"; helm --kube-context $c list -A --failed --pending
done > "$B/helm-failed-downstream-before.txt"
```

Compare with Baselines → Fleet bundles; anything listed there already failed before the upgrade.

#### 0.7 Access without Rancher works

For each downstream cluster, check that `kubectl get nodes` works from one of its server nodes (see Before you start → Access). Also check that `sudo` works on `$LOCAL_SERVER` and on every node in `$DOWNSTREAM_SERVERS`.

#### 0.8 Health checks from the SUSE checklist

```sh
curl -s https://rancher.dev.lsst.org/healthz; echo          # ok
curl -s https://rancher.dev.lsst.org/rancherversion; echo   # "Version":"v2.11.0"
kubectl --context local-dev get clusters.management.cattle.io \
  -o custom-columns='NAME:.spec.displayName,READY:.status.conditions[?(@.type=="Ready")].status,CONNECTED:.status.conditions[?(@.type=="Connected")].status'
for c in local-dev ayekan kona kueyen pukem ruka; do
  echo "== $c"
  kubectl --context $c get pods -n kube-system --no-headers | grep -vE 'Running|Completed'
  kubectl --context $c get pods -n cattle-system --no-headers | grep -vE 'Running|Completed'
done
kubectl --context local-dev get etcdsnapshotfiles.k3s.cattle.io --sort-by=.status.creationTime | tail -3
```

Expected: `ok`, all clusters `True True`, no pods listed under any cluster, and a local etcd snapshot from the last 12 hours.

### Phase 1: repo changes ✓

Done on branch `IT-7373_rancher_update` (not pushed):

- `template/rancher/rancher.sh`: `--version v2.14.3` (commit `308e02bb`). All four sites share this file through symlinks.
- `rke2/rancher.dev/rancher/values.yaml` (commit `8684583e`): `CATTLE_FLEET_MIN_VERSION` removed (see Background), and `ingress.extraAnnotations` now has `proxy-connect-timeout: "30"`, `proxy-read-timeout: "1800"` and `proxy-send-timeout: "1800"`, because 2.14 no longer adds them.
- This doc.

Optional, shared with every site: `.github/workflows/fleet-bundles.yaml:18`, Fleet CLI `v0.12.0` → `v0.15.4`.

### Phase 2: safety net (upgrade day, before touching Rancher)

#### 2.1 Announce the window and stop changes

The Rancher UI/API and Fleet reconciliation are unavailable during the upgrade; downstream workloads keep running. Tell the team, freeze merges to `dev`, and ask people not to push to the branches that ruka and kueyen track (`IT-7371_karen_slack_bot`, `IT-7345-replication-chango`). Optionally pause those two GitRepos (undo in 5.3):

```sh
kubectl --context local-dev -n it-7371-karen-bot patch gitrepo it-7371-karen-bot --type merge -p '{"spec":{"paused":true}}'
kubectl --context local-dev -n fleet-it-7345-replication-chango patch gitrepo kueyen --type merge -p '{"spec":{"paused":true}}'
```

#### 2.2 One-time Rancher backup

A `Backup` without `schedule` runs once. With no `storageLocation`, it goes to the operator's default S3 location (`rancher-bkp-dev`, folder `dev`), like the daily `s3-recurring`.

```sh
kubectl --context local-dev apply -f - <<'EOF'
apiVersion: resources.cattle.io/v1
kind: Backup
metadata:
  name: pre-upgrade-2-14-3
spec:
  resourceSetName: rancher-resource-set-full
EOF
kubectl --context local-dev wait --for=condition=Ready backups.resources.cattle.io/pre-upgrade-2-14-3 --timeout=15m
kubectl --context local-dev get backups.resources.cattle.io pre-upgrade-2-14-3 \
  -o jsonpath='{.status.filename}{"\n"}' | tee "$B/backup-pre-upgrade.txt"
```

If it doesn't finish: `kubectl --context local-dev -n cattle-resources-system logs deploy/rancher-backup -f`. The UI alternative is local cluster → Rancher Backups → Backups → Create, with no schedule.

This backup can only be restored onto Rancher 2.11 (see Background → rancher-backup), so it is not the rollback. The etcd snapshot in 2.3 is.

#### 2.3 etcd snapshot of the local cluster (required: this is the rollback)

Each snapshot holds the whole cluster's etcd data, so one server node is enough. All scheduled snapshots on these clusters are local files only, so copy it off the node.

```sh
ssh -t "$LOCAL_SERVER" 'sudo rke2 etcd-snapshot save --name pre-rancher-2.14.3 \
  && sudo cp /var/lib/rancher/rke2/server/db/snapshots/pre-rancher-2.14.3-* ~/ \
  && sudo chown $USER ~/pre-rancher-2.14.3-*'
scp "$LOCAL_SERVER:pre-rancher-2.14.3-*" "$B/etcd/"
ls -lh "$B/etcd/"
```

The original stays in `/var/lib/rancher/rke2/server/db/snapshots/` on `$LOCAL_SERVER`; you'll need that path for the Rollback section.

#### 2.4 etcd snapshots of the downstream clusters (optional, recommended)

The Rancher upgrade doesn't touch their Kubernetes or etcd, but it replaces their agents, and Fleet 0.15 redeploys every bundle with server-side apply. Restoring a downstream etcd is a last resort, but the snapshots are small (50–190 MB):

```sh
for n in $DOWNSTREAM_SERVERS; do
  ssh -t "$n" 'sudo rke2 etcd-snapshot save --name pre-rancher-2.14.3 \
    && sudo cp /var/lib/rancher/rke2/server/db/snapshots/pre-rancher-2.14.3-* ~/ \
    && sudo chown $USER ~/pre-rancher-2.14.3-*'
  scp "$n:pre-rancher-2.14.3-*" "$B/etcd/"
done
ls -lh "$B/etcd/"
```

These are imported clusters, so the Rancher UI can't take snapshots for them; the `rke2` command on the node is the only way.

### Phase 3: upgrade

#### 3.1 Pre-flight

```sh
export PATH=~/bin/rancher-upgrade:$PATH   # only if you installed the tools there (Before you start → Tools)
kubectl config use-context local-dev
kubectl config current-context      # must print local-dev: rancher.sh uses the current context
helm version --short                # 3.x, 3.18 or newer
kubectl version --client            # within one minor of the clusters' Kubernetes
helm get values rancher -n cattle-system -o yaml
cat rke2/rancher.dev/rancher/values.yaml
```

The only expected differences: the live values still have `extraEnv` with `CATTLE_FLEET_MIN_VERSION`, and the repo file has the three Ingress timeouts. `rancher.sh` passes only `-f values.yaml`, so anything else on the live side would be lost.

#### 3.2 Run the upgrade

```sh
cd rke2/rancher.dev/rancher && ./rancher.sh
```

It runs `helm repo update`, `helm upgrade --install rancher rancher-latest/rancher --version v2.14.3 -f ./values.yaml`, and then waits for `rollout status`.

#### 3.3 Watch (second terminal)

```sh
kubectl --context local-dev -n cattle-system get jobs,pods -w
kubectl --context local-dev -n cattle-system logs -l app=rancher -f --tail=50 --max-log-requests 3
```

The `rancher-pre-upgrade` hook job runs first and is deleted when it succeeds. If it fails: `kubectl --context local-dev -n cattle-system logs job/rancher-pre-upgrade`. In the Rancher logs, look for migration and Turtles errors.

Once the new Rancher pods are up, Rancher upgrades its own charts (webhook, Fleet, Turtles). Re-run this until the versions match 4.2:

```sh
helm --kube-context local-dev ls -A | grep -E 'NAME|rancher|fleet|turtles|capi'
```

### Phase 4: verify

#### 4.1 Rancher UI and version

```sh
curl -s https://rancher.dev.lsst.org/rancherversion; echo   # "Version":"v2.14.3"
```

In the browser, log in with FreeIPA as a member of `admins` and with the local admin, check the version at the bottom left, and browse clusters and workloads.

#### 4.2 Rancher's charts and settings

```sh
helm --kube-context local-dev -n cattle-system list               # rancher 2.14.3, rancher-webhook 109.x
helm --kube-context local-dev -n cattle-fleet-system list         # fleet, fleet-crd 109.0.4+up0.15.4
helm --kube-context local-dev ls -A | grep -iE 'turtles|provisioning-capi'   # turtles present, provisioning-capi gone
kubectl --context local-dev get settings.management.cattle.io fleet-min-version fleet-version \
  -o custom-columns=NAME:.metadata.name,VALUE:.value,SOURCE:.source   # min empty, fleet-version 109.0.4+up0.15.4
kubectl --context local-dev -n cattle-system get ingress rancher -o jsonpath='{.metadata.annotations}'; echo   # the 3 timeouts
```

#### 4.3 Downstream clusters and agents

```sh
kubectl --context local-dev get clusters.management.cattle.io \
  -o custom-columns='NAME:.spec.displayName,READY:.status.conditions[?(@.type=="Ready")].status,WORKSPACE:.spec.fleetWorkspaceName'
for c in ayekan kona kueyen pukem ruka; do
  printf '%-7s %s  %s\n' $c \
    "$(kubectl --context $c -n cattle-system get deploy cattle-cluster-agent -o jsonpath='{.spec.template.spec.containers[0].image}')" \
    "$(kubectl --context $c -n cattle-fleet-system get deploy fleet-agent -o jsonpath='{.spec.template.spec.containers[0].image}')"
done
```

Expected: all `True`; ruka still in `it-7371-karen-bot` and kueyen in `fleet-it-7345-replication-chango`; every cluster on `rancher/rancher-agent:v2.14.3` and `rancher/fleet-agent:v0.15.4`. An agent left on v2.11.0 is the #51066 symptom. Agent rollout can take a few minutes. Then repeat the pod check from 0.8.

#### 4.4 Fleet

```sh
kubectl --context local-dev get clusters.fleet.cattle.io -A
kubectl --context local-dev get bundles -A | awk 'NR==1 || $3!="1/1"' > "$B/bundles-not-ready-after.txt"
diff "$B/bundles-not-ready-before.txt" "$B/bundles-not-ready-after.txt"
for c in ayekan kona kueyen pukem ruka; do echo "== $c"; helm --kube-context $c list -A --failed --pending; done
```

Expected: nothing new compared with the baseline (0.6), and no new failed or pending releases (#5880: a failed Helm upgrade can still show `Ready=true`). For conflicts, see 5.1.

#### 4.5 Other checks

- A kubectl shell or log stream in the UI stays connected longer than 60s (Ingress timeouts).
- `kubectl --context local-dev get uiplugins.catalog.cattle.io -A`: the Harvester extension isn't in an error state. It isn't used, so a problem here is low impact.

### Phase 5: after the upgrade

#### 5.1 Fix problems (only if needed)

- **Bundle in `ErrApplied … conflict with "fleetagent"` (#5833) or MetalLB stuck in WaitApplied on `caBundle` (#5826):** on the affected cluster, re-apply the object with `kubectl apply --server-side --force-conflicts --field-manager=fleetagent -f <object>.yaml`, or remove the stale `managedFields` entry with `kubectl edit`. Another option is a temporary `helm.force: true` on the bundle's `fleet.yaml` (PR to `dev`).
- **Downstream cluster not `Active`:** read the agent logs from one of its server nodes (see Before you start → Access): `kubectl -n cattle-system logs deploy/cattle-cluster-agent`. If needed, re-run the cluster's registration command (cluster → Registration in the UI) there.

#### 5.2 Fresh safety net (SUSE checklist)

Repeat 2.2 with `name: post-upgrade-2-14-3` and 2.3 (and 2.4) with `--name post-rancher-2.14.3`. This snapshot becomes the restore point for 2.14.3.

#### 5.3 Lift the freeze

```sh
kubectl --context local-dev -n it-7371-karen-bot patch gitrepo it-7371-karen-bot --type merge -p '{"spec":{"paused":false}}'
kubectl --context local-dev -n fleet-it-7345-replication-chango patch gitrepo kueyen --type merge -p '{"spec":{"paused":false}}'
```

Then reopen merges to `dev`.

#### 5.4 Grace period

Leave dev in normal use for at least 24h before Phase 6, any RKE2 or OS work on dev, or starting on tu, ls or cp (order from the SUSE checklist: Rancher → Kubernetes → OS). Dev is the "test first" environment for the other three sites.

### Phase 6: rancher-backup v10 (at least 24h later)

Operator v10 is the one that matches Rancher 2.14 (see Background → rancher-backup). This goes through the normal PR flow, because Fleet deploys from `dev`.

#### 6.1 Repo change

Branch from `dev`. In both `fleet/lib/rancher-backup/fleet.yaml` and `fleet/lib/rancher-backup-crd/fleet.yaml`, add a dev-only override (the `local` cluster has the label `site: dev`):

```yaml
targetCustomizations:
  - name: dev
    clusterSelector:
      matchLabels:
        site: dev
    helm:
      version: 109.0.10+up10.0.11
```

In `template/rancher-backup/rancher-backup.sh` (shared restore script), change `104.0.2+up5.0.2` to the operator version that matches the site's Rancher, and add a comment with the v7–v11 ↔ 2.11–2.15 mapping. Open the PR to `dev` as usual.

#### 6.2 Verify after the merge

```sh
helm --kube-context local-dev -n cattle-resources-system list    # rancher-backup and -crd 109.0.10+up10.0.11
kubectl --context local-dev -n cattle-resources-system get deploy rancher-backup \
  -o jsonpath='{.spec.template.spec.containers[0].image}'; echo   # backup-restore-operator:v10.x
```

Then run a one-time backup like 2.2 (`name: post-bro-v10`) and check that the next `s3-recurring` run completes:

```sh
kubectl --context local-dev get backups.resources.cattle.io \
  -o custom-columns=NAME:.metadata.name,LAST:.status.lastSnapshotTs,FILE:.status.filename
```

---

## Rollback (only if Rancher can't be fixed forward)

The rancher-backup rollback isn't usable here (see Background), so the rollback is restoring the local etcd snapshot from 2.3. It returns the local cluster, including the Helm releases, to the moment before the upgrade. Check the RKE2 docs ("Backup and Restore", restoring a snapshot to existing nodes) for the installed version before running it.

```sh
# 1. On all three server nodes of the local cluster
sudo systemctl stop rke2-server

# 2. Only on $LOCAL_SERVER (the node that took the snapshot in 2.3)
sudo rke2 server --cluster-reset \
  --cluster-reset-restore-path=/var/lib/rancher/rke2/server/db/snapshots/pre-rancher-2.14.3-<node>-<timestamp>
sudo systemctl start rke2-server

# 3. On the other two server nodes, after $LOCAL_SERVER is up
sudo rm -rf /var/lib/rancher/rke2/server/db
sudo systemctl start rke2-server
```

Afterwards: `curl -s https://rancher.dev.lsst.org/rancherversion` should show v2.11.0. Then check the downstream agents as in 4.3. They will have been upgraded already, and whether Rancher 2.11 brings them back to v2.11.0 by itself is not verified. If a cluster stays disconnected, re-run its registration command from a server node.

Restoring a downstream cluster's snapshot (2.4) follows the same steps on that cluster's server nodes. It rolls back every Kubernetes object in that cluster, so treat it as a last resort.

---

## Baselines (2026-11-17, context `local-dev`)

### Pre-check results

| Check | Result |
|---|---|
| Local cluster | 3 nodes, control-plane + etcd, v1.35.3+rke2r1 |
| RKE1 | All 6 clusters report driver and provider `rke2`; no NodeTemplates or ClusterTemplates ✓ |
| #51066 | Not affected ✓. The provisioning objects are named `c-xxxxx` (mirrored from the management clusters), and `desiredAgentImage`, `desiredAuthImage` and `privateRegistryURL` are empty on all 5 clusters |
| Restricted Admin | No bindings ✓ |
| Feature flags | The only non-default is `provisioningv2-fleet-workspace-back-population=true` (experimental). It still exists in 2.14.3 with default false, so our value persists. `ui-sql-cache` is on by default from 2.12. `harvester=true`: the Harvester UI extension 1.5.2 is installed (state `cached`) but not used |
| Disk (SQLite cache) | Local: etcd snapshot ~0.63 GB, free 10.7–18.6 GiB on the three nodes ✓. Downstream: snapshots 50–190 MB, ~248 GiB free ✓ |
| Live Helm values vs repo | Identical except `CATTLE_FLEET_MIN_VERSION=106.0.0+up0.12.0` (now removed) ✓ |
| Ingress | Has the 30/1800/1800 timeouts today (added by the 2.11 chart). The 2.14.3 chart rendered offline with the new `values.yaml` keeps them ✓ |
| cert-manager | Controller v1.19.2, CRDs v1.14.5 |
| Rancher backups | `s3-recurring` (`rancher-resource-set-full`, every 24h) Completed 2026-11-17 01:24Z ✓ |
| etcd snapshots | Every 12h on each local server node, 5 kept on each, local files only (no S3), on all six clusters ✓ |
| Pods | Nothing outside Running/Completed in `kube-system` or `cattle-system` on any cluster ✓. `cattle-cluster-agent` 2/2 everywhere on `rancher/rancher-agent:v2.11.0` |
| Clusters | All 6 Ready=True and Connected=True ✓ |
| Access without Rancher | From a server node of each cluster ✓ (Before you start → Access) |
| Tooling | Requires Helm 3.18+ (3.x) and kubectl 1.34–1.36 (Before you start → Tools) |

### Versions on the local cluster (`helm ls -A`)

| Release | Namespace | Today | Expected after |
|---|---|---|---|
| rancher | cattle-system | 2.11.0 | 2.14.3 |
| rancher-webhook | cattle-system | `106.0.0+up0.7.0` | 109.x |
| fleet, fleet-crd | cattle-fleet-system | `106.0.0+up0.12.0` | `109.0.4+up0.15.4` |
| fleet-agent-local | cattle-fleet-local-system | Fleet 0.12.0 | Fleet 0.15.4 |
| rancher-provisioning-capi | cattle-provisioning-capi-system | `106.0.0+up0.7.0` | Removed; Turtles 109.x |
| system-upgrade-controller (deployment) | cattle-system | v0.13.4 | Rancher-managed; check |
| harvester (UI extension) | cattle-ui-plugin-system | 1.5.2 | Rancher-managed; check |
| rancher-backup, rancher-backup-crd | cattle-resources-system | `108.0.0+up9.0.0` | Unchanged until Phase 6 (`109.0.10+up10.0.11`) |
| cert-manager v1.19.2, ingress-nginx 4.15.0, metallb 0.15.2, kube-prometheus-stack 79.12.0, prometheus-operator-crds 26.0.1, external-secrets 1.3.1, onepassword-connect 1.17.1 | various | Fleet-managed | Unchanged |
| `rke2-*` charts | kube-system | RKE2 v1.35.3 (updated 2026-08-12) | Unchanged |

`metallb-conf` is at revision 214418 from old drift-correction churn. It has been quiet since 2026-11-10; watch it after Fleet 0.15 (#5826).

### Fleet bundles

`fleet-local/rancher` and every `fleet-default` GitRepo track `dev`. ruka and kueyen were moved into ticket workspaces (through the experimental back-population flag), where feature-branch GitRepos deploy to them.

| Cluster | Bundles ready | Fleet workspace |
|---|---|---|
| local | 14/15 | `fleet-local` |
| kona | 22/24 | `fleet-default` |
| pukem | 13/14 | `fleet-default` |
| ayekan | 15/20 | `fleet-default` |
| ruka | 40/48 | `it-7371-karen-bot` |
| kueyen | 17/17 | `fleet-it-7345-replication-chango` |

**Errors that already exist before the upgrade** (don't count them as regressions):

- `release has no N version` on kona `loki`, and on the ayekan and ruka `ingress-nginx` bundles.
- ayekan `cnpg-cluster`: `context deadline exceeded`.
- pukem `extended-ceph-exporter`: NotReady (`RGW_HOST` empty, progress deadline exceeded).
- ruka `htcondor`: Helm ownership conflict between the `ruka-fleet-…` and `it-7371-karen-bot-fleet-…` releases.

**Optional, the team's call (not done):** move ruka and kueyen back to `fleet-default` before the upgrade, which takes the experimental flag out of the picture. Later, clean up the 7 workspaces whose GitRepos target no cluster.

---

## Background

### Deviations from the official procedure (accepted)

Official sources: the Rancher v2.14 docs "Upgrades" page and SUSE KB 000020061 "Rancher Upgrade Checklist" (last published 2026-08-03). We knowingly don't follow these recommendations:

- **One minor at a time, starting from the latest patch of the current minor.** On Kubernetes 1.35, Helm rejects every intermediate chart (2.11.3, 2.12.x, 2.13.x), and 2.11.4+ are Prime-only. Dev is the place to find out whether the direct jump works.
- **Staying inside the support matrix.** Dev is already outside it (2.11.0 on Kubernetes 1.35); this upgrade brings it back in.
- **Incremental Kubernetes minors and the 1.33 etcd 3.6 migration note.** The clusters are already on 1.35.
- **Rollback with rancher-backup.** Not usable here (see "Why the rollback is an etcd snapshot"); we use an etcd snapshot instead.
- **Upgrade feature charts to their latest patch first.** rancher-backup is handled in Phase 6; the Harvester UI extension is managed by Rancher.
- **Not relevant to this setup:** air-gap installs, cert-manager older than 0.8, and the KB's example Prime upgrade plan.

**The risk this leaves:** nothing in the code blocks the jump. The chart's pre-upgrade hook only checks for RKE1 resources, plus the chart's `kubeVersion: < 1.36`. But the automatic migrations, Turtles replacing the embedded CAPI (2.13) and CAPI moving to v1beta2 (2.14), were never tested starting from 2.11.

### Where each official step is covered

| Official step | Source | Runbook step |
|---|---|---|
| UI reachable, clusters Active, `kube-system`/`cattle-system` pods Running, scheduled etcd snapshots working | KB | 0.8 |
| Pause anything that uses the Rancher API | KB | 2.1 |
| Rancher Backup operator backup | Docs, KB | 2.2 |
| On-demand snapshot of the local cluster | KB | 2.3 |
| `helm repo update` | Docs | 3.2 (`rancher.sh`) |
| `helm get values rancher -n cattle-system -o yaml`, reuse the values | Docs | 3.1 |
| `helm upgrade rancher … -f values.yaml --version …` | Docs | 3.2 (`rancher.sh`) |
| Login, new version in the UI, clusters Active, pods Running, agents on the new version | Docs, KB | 4.1, 4.3 |
| Fresh backup and snapshot after the upgrade | KB | 5.2 |
| Order Rancher → Kubernetes → OS, grace period between upgrades | KB | 5.4 |

The related KB "Rancher 2.11 to 2.12 Upgrade Checklist (Audit Logs, Clusters, UI Cache)", linked from #51066, wasn't retrieved. The topics in its title are covered: clusters (#51066), the UI cache disk requirement, and we don't configure `auditLog`.

### Rancher changes that affect dev (2.12 → 2.14)

| Version | Change | What it means here |
|---|---|---|
| 2.12 | RKE1 removed; the pre-upgrade hook **fails** if any RKE1 cluster, NodeTemplate or ClusterTemplate exists | None on dev ✓. `rke2/kueyen/README.md` still has `rke up` text, but the cluster is RKE2 |
| 2.12 | SQLite UI cache on by default; needs free disk of about **2× the etcd snapshot size** on local nodes and on nodes running `cattle-cluster-agent` | Enough disk everywhere ✓ |
| 2.12 | Restricted Admin removed; its privileges are revoked | No bindings ✓ |
| 2.12 | #51066 (closed, not planned): imported clusters created through `clusters.provisioning.cattle.io` objects on 2.11 keep the 2.11 agent and disconnect | Not affected ✓; checked again in 4.3 |
| 2.12–2.14 | `tokens.ext.cattle.io` added; `tokens.management.cattle.io` deprecated but still works | Only matters for API automation |
| 2.13 / 2.14 | Turtles replaces the embedded CAPI (`rancher-provisioning-capi` removed); CAPI moves to v1beta2 | Migrates automatically; checked in 4.2 |
| 2.14 | Rancher's Ingress no longer adds `nginx.ingress.kubernetes.io/proxy-{connect,read,send}-timeout` (30/1800/1800); only the deprecated `ingress.includeDefaultExtraAnnotations` brings them back | Added to `ingress.extraAnnotations` ✓ |
| 2.14 | Code for end-of-life cert-manager versions removed | Controller v1.19.2 ✓. CRDs are v1.14.5, a pre-existing mismatch |
| 2.14.2 | `project-owner` loses `updatepsa` | Low risk |

No release note in this range mentions LDAP/FreeIPA, `agent-tls-mode` or audit logging in a way that affects this setup. **The 2.15-only cluster-registration-token migration (#57078) does not exist in 2.14.3**; neither the migration code nor the `crt-token-ttl-rotation` flag is there. ✓

### Why `CATTLE_FLEET_MIN_VERSION` was removed

- **What it does** (`pkg/controllers/dashboard/fleetcharts/controller.go`): if set, it **replaces** the bundled `fleet-version`. Rancher installs that exact chart version only when the installed Fleet is older, and never downgrades (`pkg/catalogv2/system/system.go`).
- **Why a stale value is dangerous:** the system chart catalog still contains old versions such as `106.0.0+up0.12.0`. A stale value would make Rancher **silently skip the Fleet upgrade**. Dev has it set to `106.0.0+up0.12.0` today (`fleet-min-version` and `fleet-version` both show it, source `env`).
- **Without it (v2.14.3):** the image declares `ENV CATTLE_FLEET_MIN_VERSION=""` (`package/Dockerfile:223-226`), and `SetAll()` sets the stored value to empty (`pkg/controllers/dashboardapi/settings/settings.go:139-155`). Rancher then installs the bundled **`109.0.4+up0.15.4`** (Fleet 0.15.4), and future Rancher upgrades bring their matching Fleet automatically.
- **Other sites:** tu, ls and cp still pin `106.0.0+up0.12.0` and need the same removal when they upgrade.

### Fleet 0.12.0 → 0.15.4 (131 bundle deployments on dev)

**0.15 moves to Helm v4 with server-side apply.** These issues are still open:

- **#5833:** field-ownership conflicts with objects created by the old agent, leading to `ErrApplied` and dependent bundles stuck in WaitApplied. 35 bundles use `dependsOn`; CRD bundles are most exposed. Maintainers couldn't reproduce it.
- **#5880:** a failed Helm upgrade can still show `Ready=true`. Check Helm release status on the downstream clusters.
- **#6015:** `takeOwnership` (22 bundles) conflicts with server-side apply.
- **#5826:** **MetalLB** CRD `caBundle` conflict leaves bundles stuck in WaitApplied. It was reported on Fleet 0.16 but is likely to also hit 0.15 (not verified). Dev runs `metallb` and `metallb-conf`.

**Bugs in 0.15.4 that are fixed only in 0.16:**

- **#5443:** the "wrong node kind" error when a template has a leading `#` comment or dash run. The repo's own templates have none; upstream charts weren't scanned.
- **#4210:** `namespaceLabels` set in `targetCustomizations` leak to other clusters. None found in the repo.

**Other changes:**

- **0.13:** BundleDeployments that are no longer targeted now get deleted. This only matters when targeting changes; the GitRepos keep `keepResources: true`.
- **Checked, not applicable to this repo:** SSH host-key enforcement (all GitRepos use HTTPS), `imageScans` off by default (not used), PSA labels in `namespaceLabels` (none), `name:` longer than 53 characters (#5261; no `name:` fields), the Helm credential regex (`helmSecretName` not used).
- No `fleet.yaml` fields the repo uses were removed or renamed between 0.12 and 0.15.
- **CI:** the Fleet CLI is only used for offline `fleet apply -o /dev/null`, so moving it to `v0.15.4` is safe.

### rancher-backup (backup-restore-operator)

- **Version matching:** each operator major goes with one Rancher minor (`VERSION.md`): v7 = 2.11, v8 = 2.12, v9 = 2.13, **v10 = 2.14**.
- **Today:** Fleet deploys `108.0.0+up9.0.0` (built for 2.13, Kubernetes `< 1.35`) to all four sites. On dev it was installed 2026-02-03, before RKE2 moved to 1.35 (2026-08-12), so any re-deploy of that chart now fails the `kubeVersion` check. One more reason for Phase 6.
- **Target for 2.14:** chart **`109.0.10+up10.0.11`** for both `rancher-backup` and `rancher-backup-crd`. v10 adds the CAPI v1beta2 objects and merges CRD versions during restore.
- **Stricter CRDs:** since chart 109.0.10, the Backup and Restore CRDs require `s3.bucketName` **and** `s3.endpoint` in any explicit `storageLocation`. Our Backup and Restore resources don't set `storageLocation`; they use the chart's default S3 location, which sets `endpoint`. ✓
- **Restores need the same Rancher version.** A pre-upgrade (2.11) backup can only be restored onto 2.11.
- **The restore script is outdated:** `template/rancher-backup/rancher-backup.sh` pins `104.0.2+up5.0.2` (the Rancher 2.9 era).

### Why the rollback is an etcd snapshot

- **The documented rollback isn't practical.** A rancher-backup rollback from 2.14 needs rancher-cleanup plus a migration-style restore (v2.14 `rollbacks.md`; BRO#844 and #1329 are open), and Helm rejects the 2.11 chart on Kubernetes 1.35.
- **Practical rollback:** an RKE2 etcd snapshot of the local cluster, taken just before the upgrade and restored with cluster-reset (see Rollback).
- **Not verified:** whether the downstream agents, already upgraded, downgrade cleanly afterwards.

---

## Open items / not verified

- Rollback through etcd restore once the downstream agents are already upgraded.
- Restoring a v9 backup (taken on 2.11) with v7 or v10.
- Whether #5833 and #5826 actually happen here.
- Upstream charts weren't scanned for #5443 triggers.
- Future work: tu, ls and cp (shared `rancher.sh`, their own `CATTLE_FLEET_MIN_VERSION`, shared rancher-backup 108). The upstream retirement of ingress-nginx (March 2026).

---

## Appendix: v2.15.3 (the alternative we looked at, not chosen)

If a later move to 2.15.3 is needed, from 2.14.3 that's the supported one-minor step. Differences from 2.14.3:

- **Versions:** chart `kubeVersion < 1.37`; Kubernetes 1.34–1.36 supported. Bundled Fleet `110.0.3+up0.16.3`, webhook `110.0.4+up0.11.4`, turtles `110.0.4+up0.27.4`. rancher-backup v11 `110.0.3+up11.0.4` (`kubeVersion >= 1.34`).
- **New risk, #57078 (open):** imported clusters become `Unavailable` after the 2.15 migration of cluster-registration tokens into Secrets. The new `crt-token-ttl-rotation` flag is on by default. #58028 (empty token) is fixed in 2.15.3. Workaround: re-run the registration command; maybe disable the flag.
- **Fleet 0.16.3 fixes** #5443, #4210 and #5261, plus the PSA `namespaceLabels` bug. Still open: #5833, #5880, #6015 and #5826.
- **Fleet 0.16.3, new issue #6154:** drift-watcher loop every 5s after a `410 Gone`. Every GitRepo uses `correctDrift`.
- **Fleet 0.16.3, other changes:** credentials now need `helmRepoURLRegex` (not used here), duration validation, and ServiceAccount impersonation (2.15.2; no GitRepo pins a `serviceAccount`).
- **Other:** the SQLite cache can't be turned off; `/v1` returns a collection (#57463); `busyboxImage*` values are ignored; #58075 (stale env settings) is fixed in 2.15.3.
