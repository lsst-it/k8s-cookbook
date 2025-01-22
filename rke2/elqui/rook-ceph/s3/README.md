# Table of Contents

- [User Creation](#user-creation)
- [Bucket Creation and Quotas](#bucket-creation-and-quotas)
- [Apply Policies to the Buckets](#apply-policies-to-the-buckets)
- [Lifecycle Policy Configuration for Buckets](#lifecycle-policy-configuration-for-buckets)
- [Check Current Policy](#check-current-policy)

## This Policies need to be applied in the corresponding buckets for the users to grab permissions

## User Creation

### User creation was replaced with cephObjectStoreUser Kubernetes CRD

## Bucket Creation and Quotas

```bash
aws s3 --profile s3-cp-latiss mb s3://rubinobs-raw-latiss --endpoint-url https://s3.cp.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-raw-latiss --quota-scope=bucket --max-size=1T
radosgw-admin quota enable --bucket=rubinobs-raw-latiss
radosgw-admin bucket stats --bucket=rubinobs-raw-latiss --rgw-realm=s3-butler

aws s3 --profile s3-cp-latiss mb s3://rubinobs-butler-latiss --endpoint-url https://s3.cp.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-butler-latiss --quota-scope=bucket --max-size=10T
radosgw-admin quota enable --bucket=rubinobs-butler-latiss
radosgw-admin bucket stats --bucket=rubinobs-butler-latiss

aws s3 --profile s3-cp-lsstcam mb s3://rubinobs-raw-lsstcam --endpoint-url https://s3.cp.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-raw-lsstcam --quota-scope=bucket --max-size=200T
radosgw-admin quota enable --bucket=rubinobs-raw-lsstcam
radosgw-admin bucket stats --bucket=rubinobs-raw-lsstcam

aws s3 --profile s3-cp-lsstcam mb s3://rubinobs-butler-lsstcam --endpoint-url https://s3.cp.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-butler-lsstcam --quota-scope=bucket --max-size=34T
radosgw-admin quota enable --bucket=rubinobs-butler-lsstcam
radosgw-admin bucket stats --bucket=rubinobs-butler-lsstcam

aws s3 --profile s3-cp-comcam mb s3://rubinobs-raw-comcam --endpoint-url https://s3.cp.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-raw-comcam --quota-scope=bucket --max-size=5T
radosgw-admin quota enable --bucket=rubinobs-raw-comcam
radosgw-admin bucket stats --bucket=rubinobs-raw-comcam

aws s3 --profile s3-cp-comcam mb s3://rubinobs-butler-comcam --endpoint-url https://s3.cp.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-butler-comcam --quota-scope=bucket --max-size=34T
radosgw-admin quota enable --bucket=rubinobs-butler-comcam
radosgw-admin bucket stats --bucket=rubinobs-butler-comcam

aws s3 --profile s3-cp-calib mb s3://rubinobs-calibrations --endpoint-url https://s3.cp.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-calibrations --quota-scope=bucket --max-size=10T
radosgw-admin quota enable --bucket=rubinobs-calibrations
radosgw-admin bucket stats --bucket=rubinobs-calibrations
```

## Apply Policies to the Buckets

```bash
aws s3api --profile s3-cp-latiss put-bucket-policy --bucket rubinobs-raw-latiss --policy file://users-rubinobs-raw-latiss-policy.json --endpoint-url https://s3.cp.lsst.org --region lfa
aws s3api --profile s3-cp-latiss put-bucket-policy --bucket rubinobs-butler-latiss --policy file://users-rubinobs-butler-latiss-policy.json --endpoint-url https://s3.cp.lsst.org --region lfa
aws s3api --profile s3-cp-lsstcam put-bucket-policy --bucket rubinobs-raw-lsstcam --policy file://users-rubinobs-raw-lsstcam-policy.json --endpoint-url https://s3.cp.lsst.org --region lfa
aws s3api --profile s3-cp-lsstcam put-bucket-policy --bucket rubinobs-butler-lsstcam --policy file://users-rubinobs-butler-lsstcam-policy.json --endpoint-url https://s3.cp.lsst.org --region lfa
aws s3api --profile s3-cp-comcam put-bucket-policy --bucket rubinobs-raw-comcam --policy file://users-rubinobs-raw-comcam-policy.json --endpoint-url https://s3.cp.lsst.org --region lfa
aws s3api --profile s3-cp-comcam put-bucket-policy --bucket rubinobs-butler-comcam --policy file://users-rubinobs-butler-comcam-policy.json --endpoint-url https://s3.cp.lsst.org --region lfa
aws s3api --profile s3-cp-calib put-bucket-policy --bucket rubinobs-calibrations --policy file://users-rubinobs-calibrations-policy.json --endpoint-url https://s3.cp.lsst.org --region lfa
```

## Lifecycle Policy Configuration for Buckets

```bash
aws s3api put-bucket-lifecycle-configuration --profile lfa-cp --no-verify-ssl --region lfa --bucket rubinobs-lfa-cp --lifecycle-configuration file://rubinobs-lfa-cp-lifecycle.json
aws s3api put-bucket-lifecycle-configuration --profile s3-cp-latiss --no-verify-ssl --region lfa --bucket rubinobs-butler-latiss --lifecycle-configuration file://rubinobs-butler-lifecycle.json
aws s3api put-bucket-lifecycle-configuration --profile s3-cp-latiss --no-verify-ssl --region lfa --bucket rubinobs-raw-latiss --lifecycle-configuration file://rubinobs-butler-lifecycle.json
aws s3api put-bucket-lifecycle-configuration --profile s3-cp-lsstcam --no-verify-ssl --region lfa --bucket rubinobs-raw-lsstcam --lifecycle-configuration file://rubinobs-butler-lifecycle.json
aws s3api put-bucket-lifecycle-configuration --profile s3-cp-lsstcam --no-verify-ssl --region lfa --bucket rubinobs-butler-lsstcam --lifecycle-configuration file://rubinobs-butler-lifecycle.json
aws s3api put-bucket-lifecycle-configuration --profile s3-cp-comcam --no-verify-ssl --region lfa --bucket rubinobs-raw-comcam --lifecycle-configuration file://rubinobs-butler-lifecycle.json
aws s3api put-bucket-lifecycle-configuration --profile s3-cp-comcam --no-verify-ssl --region lfa --bucket rubinobs-butler-comcam --lifecycle-configuration file://rubinobs-butler-lifecycle.json
```

## Check Current Policy

```bash
aws s3api get-bucket-lifecycle-configuration --profile lfa-cp --no-verify-ssl --region lfa --bucket rubinobs-lfa-cp
aws s3api get-bucket-lifecycle-configuration --profile s3-cp-latiss --no-verify-ssl --region lfa --bucket rubinobs-butler-latiss
aws s3api get-bucket-lifecycle-configuration --profile s3-cp-latiss --no-verify-ssl --region lfa --bucket rubinobs-raw-latiss
aws s3api get-bucket-lifecycle-configuration --profile s3-cp-lsstcam --no-verify-ssl --region lfa --bucket rubinobs-raw-lsstcam
aws s3api get-bucket-lifecycle-configuration --profile s3-cp-lsstcam --no-verify-ssl --region lfa --bucket rubinobs-butler-lsstcam
aws s3api get-bucket-lifecycle-configuration --profile s3-cp-comcam --no-verify-ssl --region lfa --bucket rubinobs-raw-comcam
aws s3api get-bucket-lifecycle-configuration --profile s3-cp-comcam --no-verify-ssl --region lfa --bucket rubinobs-butler-comcam
```
