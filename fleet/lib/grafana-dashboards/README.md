# Grafana dashboard GitOps

Adding a dashboard JSON to the dashboards folder in this directory, will
automagically deploy them into the `lsst-grafana-dashboard` namespace in the
cluster. If `kube-prometheus-stack` is deployed, it can be configured to pick up
this namespace for monitoring.

Numeric subdirectories in the `/dashboards` folder can be used to assign an
organisation ID to the dashboards being uploaded. Dashboards under `/dashboards`
are automatically assigned `1`. For examples dashboards under `/dashboards/3`
will have organisation ID `3` and under `/dashboards/45` will have organisation
ID `45`.

## Adding global dashboards

1. Create and export the JSON representation of the dashboards.
2. Strip the UNIX timespamp from the filename
3. Add the dashboard to the `/dashboards` directory.
4. Commit

## Adding dashboard to specific Grafana organisation

1. Create and export the JSON representation of the dashboards.
2. Strip the UNIX timespamp from the filename
3. Check if a subdirectory with the `OrgID` of the Grafana organisation exists in
   the `/dashboards` directory.
3. If it doesn't exist, create the `/dashboards/<orgid>` subdirectory.
4. Add the dashboard to the `/dashboards/<orgid>` directory.
5. Commit
