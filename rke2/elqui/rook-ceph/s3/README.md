# Lifecycle

## Lifecycle Policy Configuration

```bash
aws s3api put-bucket-lifecycle-configuration --region lfa --bucket rubinobs-lfa-cp --ca-bundle /etc/ssl/certs/ca-bundle.crt --endpoint-url https://s3.elqui.cp.lsst.org --lifecycle-configuration file://rubinobs-lfa-cp-lifecycle.json
aws s3api get-bucket-lifecycle-configuration --region lfa --bucket rubinobs-lfa-cp --ca-bundle /etc/ssl/certs/ca-bundle.crt --endpoint-url https://s3.elqui.cp.lsst.org
```

## Bucket Policy Configuration

```bash
aws s3api put-bucket-policy --region lfa --bucket rubinobs-lfa-cp --ca-bundle /etc/ssl/certs/ca-bundle.crt --endpoint-url https://s3.elqui.cp.lsst.org --policy file://rubinobs-lfa-cp-policy.json
aws s3api get-bucket-policy --region lfa --bucket rubinobs-lfa-cp --ca-bundle /etc/ssl/certs/ca-bundle.crt --endpoint-url https://s3.elqui.cp.lsst.org
```
