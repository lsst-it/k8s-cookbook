# Nexus Repository

Sonatype Nexus Repository Pro, single instance, deployed with the official
[`nxrm-ha`](https://github.com/sonatype/nxrm3-ha-repository) chart from
`https://sonatype.github.io/helm3-charts`. The database is the CNPG cluster from
the `nexus-pg` bundle and the secrets come from the `nexus-pre` bundle.

## Versions

The image tag is not overridden: the chart's `appVersion` is the Nexus version
(chart `98.2.0` -> Nexus `3.98.2`). Bumping `helm.version` in `fleet.yaml`
upgrades Nexus.

The chart sets `updateStrategy: OnDelete` on the StatefulSet, so the pod does
not restart on its own after a bump. Once Fleet has applied the new version:

```bash
kubectl -n nexus delete pod nexus-nxrm-ha-0
```

Nexus migrates the database schema on startup; the startup probe allows up to
30 minutes.

## License

The chart mounts the secret named `secret.license.name` and reads the key with
the same name, so the secret and key are both `nexus-repo-license.lic`. The
`nexus-pre` ExternalSecret renames whatever `.lic` file is attached to the
1Password item to that key. To renew the license, replace the file in
1Password (keep a single `.lic` file in the item); no git change is needed.

## Storage

The data PVC is declared in `kustomize/` and referenced by the chart through
`pvc.existingClaim`. Its name, `data-nexus-nexus3-0`, comes from the previous
chart (`stevehipwell/nexus3`) and was kept so the existing volumes are adopted.

Kustomize is used, like in `mimir` and `loki`, because Fleet ignores
`yaml.overlays` and plain YAML files in bundles that deploy a Helm chart; it
only adds extra resources to a chart through kustomize.

- The default PVC (10Gi) is `kustomize/base/pvc-nexus-data.yaml`; clusters
  without their own overlay use it.
- A cluster that needs another size gets `kustomize/overlays/<cluster>/`
  (a `kustomization.yaml` with `../../base` plus a patch) and a
  `targetCustomizations` entry in `fleet.yaml` with `kustomize.dir` pointing to
  it (see `yepun`).
- Volumes can only grow. Raise the size in git and the volume is expanded
  online; shrinking is rejected by the API.
- Keep the `helm.sh/resource-policy: keep` annotation: the storage class
  deletes the underlying volume when the PVC is deleted.

Per-cluster Helm values for this bundle follow the usual pattern: add
`overlays/<cluster>/values.yaml` and list it under `helm.valuesFiles` in a
`targetCustomizations` entry of `fleet.yaml`.
