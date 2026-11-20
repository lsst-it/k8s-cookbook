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

## Bumping Nexus

Chart and Nexus versions map one to one: chart `A.B.C` ships Nexus `3.A.B`, and
`C` is a chart-only revision (for example chart `98.2.0` -> Nexus `3.98.2`).

1. Read the release notes for the target Nexus version (and the versions
   between) for upgrade notes:
   <https://help.sonatype.com/en/release-notes.html>
2. Find the chart version that ships it:

   ```bash
   helm repo add sonatype https://sonatype.github.io/helm3-charts
   helm repo update sonatype
   helm search repo sonatype/nxrm-ha --versions | head
   # or check one chart version directly
   helm show chart nxrm-ha --repo https://sonatype.github.io/helm3-charts --version 98.2.0 | grep appVersion
   ```

3. Compare the default values of the current and target chart versions for
   renamed or new keys:

   ```bash
   diff <(helm show values nxrm-ha --repo https://sonatype.github.io/helm3-charts --version <current>) \
        <(helm show values nxrm-ha --repo https://sonatype.github.io/helm3-charts --version <target>)
   ```

4. Set `helm.version` in `fleet.yaml` to the target chart version. Renovate
   also opens these bumps.
5. Test on a dev cluster first, then delete the pod as shown above so the new
   version starts.
