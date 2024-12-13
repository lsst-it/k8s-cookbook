# This lifecycle policy is made to be applied in the LFA in the TTS

## to apply this policy of lifecycle with retention period of 30 days use

```bash
aws s3api put-bucket-lifecycle-configuration --profile lfa-tu --no-verify-ssl --region lfa --bucket rubinobs-lfa-tuc --lifecycle-configuration file://lfa-tu-lifecycle.json
```

## to check on the current policy use

```bash
aws s3api get-bucket-lifecycle-configuration --profile lfa-tu --no-verify-ssl --region lfa --bucket rubinobs-lfa-tuc
```
