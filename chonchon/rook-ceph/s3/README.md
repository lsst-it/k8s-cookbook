# Lifecycle

## Lifecycle Policy Configuration for Buckets

```bash
aws s3api put-bucket-lifecycle-configuration --profile lfa-cp --no-verify-ssl --region lfa --bucket rubinobs-lfa-cp --lifecycle-configuration file://lfa-cp-lifecycle.json
```

## Check Current Policy

```bash
aws s3api get-bucket-lifecycle-configuration --profile lfa-cp --no-verify-ssl --region lfa --bucket rubinobs-lfa-cp
```
