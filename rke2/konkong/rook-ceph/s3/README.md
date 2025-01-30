# Table of Contents

- [User Creation](#user-creation)
- [Bucket Creation and Quotas](#bucket-creation-and-quotas)
- [Apply Policies to the Buckets](#apply-policies-to-the-buckets)
- [Lifecycle Policy Configuration for Buckets](#lifecycle-policy-configuration-for-buckets)
- [Check Current Policy](#check-current-policy)

## This Policies need to be applied in the corresponding buckets for the users to grab permissions

## User Creation

Users are now created using rook's custom resource called "CephObjectStoreUser"

## Bucket Creation and Quotas

```bash
aws s3 --profile s3-bts-latiss mb s3://rubinobs-raw-latiss --endpoint-url https://s3-butler.ls.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-raw-latiss --rgw-zone=lfa --rgw-zonegroup=lfa --rgw-realm=lfa --quota-scope=bucket --max-size=1T
radosgw-admin quota enable --bucket=rubinobs-raw-latiss --rgw-zone=lfa --rgw-zonegroup=lfa --rgw-realm=lfa
radosgw-admin bucket stats --bucket=rubinobs-raw-latiss --rgw-zone=lfa

aws s3 --profile s3-bts-latiss mb s3://rubinobs-butler-latiss --endpoint-url https://s3-butler.ls.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-butler-latiss --rgw-zone=lfa --rgw-zonegroup=lfa --rgw-realm=lfa --quota-scope=bucket --max-size=1T
radosgw-admin quota enable --bucket=rubinobs-butler-latiss --rgw-zone=lfa --rgw-zonegroup=lfa --rgw-realm=lfa
radosgw-admin bucket stats --bucket=rubinobs-butler-latiss --rgw-zone=lfa

aws s3 --profile s3-bts-lsstcam mb s3://rubinobs-raw-lsstcam --endpoint-url https://s3-butler.ls.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-raw-lsstcam --rgw-zone=lfa --rgw-zonegroup=lfa --rgw-realm=lfa --quota-scope=bucket --max-size=6T
radosgw-admin quota enable --bucket=rubinobs-raw-lsstcam --rgw-zone=lfa --rgw-zonegroup=lfa --rgw-realm=lfa
radosgw-admin bucket stats --bucket=rubinobs-raw-lsstcam --rgw-zone=lfa

aws s3 --profile s3-bts-lsstcam mb s3://rubinobs-butler-lsstcam --endpoint-url https://s3-butler.ls.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-butler-lsstcam --rgw-zone=lfa --rgw-zonegroup=lfa --rgw-realm=lfa --quota-scope=bucket --max-size=34T
radosgw-admin quota enable --bucket=rubinobs-butler-lsstcam --rgw-zone=lfa --rgw-zonegroup=lfa --rgw-realm=lfa
radosgw-admin bucket stats --bucket=rubinobs-butler-lsstcam --rgw-zone=lfa

aws s3 --profile s3-bts-calib mb s3://rubinobs-calibrations --endpoint-url https://s3-butler.ls.lsst.org --region lfa
radosgw-admin quota set --bucket=rubinobs-calibrations --rgw-zone=lfa --rgw-zonegroup=lfa --rgw-realm=lfa --quota-scope=bucket --max-size=4T
radosgw-admin quota enable --bucket=rubinobs-calibrations --rgw-zone=lfa --rgw-zonegroup=lfa --rgw-realm=lfa
radosgw-admin bucket stats --bucket=rubinobs-calibrations --rgw-zone=lfa
```

## Apply Policies to the Buckets

```bash
aws s3api --profile s3-bts-latiss put-bucket-policy --bucket rubinobs-raw-latiss --policy file://users-rubinobs-raw-latiss-policy.json --endpoint-url https://s3-butler.ls.lsst.org --region lfa
aws s3api --profile s3-bts-latiss put-bucket-policy --bucket rubinobs-butler-latiss --policy file://users-rubinobs-butler-latiss-policy.json --endpoint-url https://s3-butler.ls.lsst.org --region lfa
aws s3api --profile s3-bts-lsstcam put-bucket-policy --bucket rubinobs-raw-lsstcam --policy file://users-rubinobs-raw-lsstcam-policy.json --endpoint-url https://s3-butler.ls.lsst.org --region lfa
aws s3api --profile s3-bts-lsstcam put-bucket-policy --bucket rubinobs-butler-lsstcam --policy file://users-rubinobs-butler-lsstcam-policy.json --endpoint-url https://s3-butler.ls.lsst.org --region lfa
aws s3api --profile s3-bts-calib put-bucket-policy --bucket rubinobs-calibrations --policy file://users-rubinobs-calibrations-policy.json --endpoint-url https://s3-butler.ls.lsst.org --region lfa
```

## Lifecycle Policy Configuration for Buckets

```bash
aws s3api put-bucket-lifecycle-configuration --profile lfa-ls --no-verify-ssl --region lfa --bucket rubinobs-lfa-ls --lifecycle-configuration file://lfa-ls-lifecycle.json
aws s3api put-bucket-lifecycle-configuration --profile s3-bts-latiss --no-verify-ssl --region lfa --bucket rubinobs-butler-latiss --lifecycle-configuration file://rubinobs-butler-lifecycle.json
aws s3api put-bucket-lifecycle-configuration --profile s3-bts-latiss --no-verify-ssl --region lfa --bucket rubinobs-raw-latiss --lifecycle-configuration file://rubinobs-butler-lifecycle.json
aws s3api put-bucket-lifecycle-configuration --profile s3-bts-lsstcam --no-verify-ssl --region lfa --bucket rubinobs-raw-lsstcam --lifecycle-configuration file://rubinobs-butler-lifecycle.json
aws s3api put-bucket-lifecycle-configuration --profile s3-bts-lsstcam --no-verify-ssl --region lfa --bucket rubinobs-butler-lsstcam --lifecycle-configuration file://rubinobs-butler-lifecycle.json
```

## Check Current Policy

```bash
aws s3api get-bucket-lifecycle-configuration --profile lfa-ls --no-verify-ssl --region lfa --bucket rubinobs-lfa-ls
aws s3api get-bucket-lifecycle-configuration --profile s3-bts-latiss --no-verify-ssl --region lfa --bucket rubinobs-butler-latiss
aws s3api get-bucket-lifecycle-configuration --profile s3-bts-latiss --no-verify-ssl --region lfa --bucket rubinobs-raw-latiss
aws s3api get-bucket-lifecycle-configuration --profile s3-bts-lsstcam --no-verify-ssl --region lfa --bucket rubinobs-raw-lsstcam
aws s3api get-bucket-lifecycle-configuration --profile s3-bts-lsstcam --no-verify-ssl --region lfa --bucket rubinobs-butler-lsstcam
```
