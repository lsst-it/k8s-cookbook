# Table of Contents

- [User Creation](#user-creation)
- [Bucket Creation and Quotas](#bucket-creation-and-quotas)
- [Apply Policies to the Buckets](#apply-policies-to-the-buckets)
- [Lifecycle Policy Configuration for Buckets](#lifecycle-policy-configuration-for-buckets)
- [Check Current Policy](#check-current-policy)

## This Policies need to be applied in the corresponding buckets for the users to grab permissions

## User Creation

```bash
radosgw-admin user create --uid=latiss  --display-name="latiss account"  --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler --access-key= --secret-key=
radosgw-admin user create --uid=lsstcam --display-name="lsstcam account" --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler --access-key= --secret-key=
radosgw-admin user create --uid=butler  --display-name="butler account"  --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler --access-key= --secret-key=
radosgw-admin user create --uid=oods-latiss  --display-name="oods latiss account"  --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler --access-key= --secret-key=
radosgw-admin user create --uid=oods-lsstcam  --display-name="oods lsstcam account"  --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler --access-key= --secret-key=
```

## Bucket Creation and Quotas

```bash
aws s3 --profile s3-bts-latiss mb s3://rubinobs-raw-latiss --endpoint-url https://s3-butler.ls.lsst.org --region s3-butler
radosgw-admin quota set --bucket=rubinobs-raw-latiss --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler --quota-scope=bucket --max-size=1T
radosgw-admin quota enable --bucket=rubinobs-raw-latiss --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler
radosgw-admin bucket stats --bucket=rubinobs-raw-latiss --rgw-realm=s3-butler

aws s3 --profile s3-bts-latiss mb s3://rubinobs-butler-latiss --endpoint-url https://s3-butler.ls.lsst.org --region s3-butler
radosgw-admin quota set --bucket=rubinobs-butler-latiss --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler --quota-scope=bucket --max-size=1T
radosgw-admin quota enable --bucket=rubinobs-butler-latiss --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler
radosgw-admin bucket stats --bucket=rubinobs-butler-latiss --rgw-realm=s3-butler

aws s3 --profile s3-bts-lsstcam mb s3://rubinobs-raw-lsstcam --endpoint-url https://s3-butler.ls.lsst.org --region s3-butler
radosgw-admin quota set --bucket=rubinobs-raw-lsstcam --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler --quota-scope=bucket --max-size=6T
radosgw-admin quota enable --bucket=rubinobs-raw-lsstcam --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler
radosgw-admin bucket stats --bucket=rubinobs-raw-lsstcam --rgw-realm=s3-butler

aws s3 --profile s3-bts-lsstcam mb s3://rubinobs-butler-lsstcam --endpoint-url https://s3-butler.ls.lsst.org --region s3-butler
radosgw-admin quota set --bucket=rubinobs-butler-lsstcam --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler --quota-scope=bucket --max-size=34T
radosgw-admin quota enable --bucket=rubinobs-butler-lsstcam --rgw-zone=s3-butler --rgw-zonegroup=s3-butler --rgw-realm=s3-butler
radosgw-admin bucket stats --bucket=rubinobs-butler-lsstcam --rgw-realm=s3-butler
```

## Apply Policies to the Buckets

```bash
aws s3api --profile s3-bts-latiss put-bucket-policy --bucket rubinobs-raw-latiss --policy file://users-rubinobs-raw-latiss-policy.json --endpoint-url https://s3-butler.ls.lsst.org --region s3-butler
aws s3api --profile s3-bts-latiss put-bucket-policy --bucket rubinobs-butler-latiss --policy file://users-rubinobs-butler-latiss-policy.json --endpoint-url https://s3-butler.ls.lsst.org --region s3-butler
aws s3api --profile s3-bts-lsstcam put-bucket-policy --bucket rubinobs-raw-lsstcam --policy file://users-rubinobs-raw-lsstcam-policy.json --endpoint-url https://s3-butler.ls.lsst.org --region s3-butler
aws s3api --profile s3-bts-lsstcam put-bucket-policy --bucket rubinobs-butler-lsstcam --policy file://users-rubinobs-butler-lsstcam-policy.json --endpoint-url https://s3-butler.ls.lsst.org --region s3-butler
```

## Lifecycle Policy Configuration for Buckets

```bash
aws s3api put-bucket-lifecycle-configuration --profile lfa-ls --no-verify-ssl --region lfa --bucket rubinobs-lfa-ls --lifecycle-configuration file://lfa-ls-lifecycle.json
```

## Check Current Policy

```bash
aws s3api get-bucket-lifecycle-configuration --profile lfa-ls --no-verify-ssl --region lfa --bucket rubinobs-lfa-ls
```
