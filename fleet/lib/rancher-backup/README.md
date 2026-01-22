# Rancher Backup Operator Fleet Bundle

## Requirements

For this bundle to work properly, complete the following steps:

### 1. Create an IAM User in AWS

- Create an IAM user in AWS named `rancher-backup-(site)`.
- Generate an **AccessKey**, but **do not allow console access**.

### 2. Store User Credentials

- Save the generated credentials in **1Password**.
- Store them in the `k8s.(site)` vault, named **"rancher-backup"**.

### 3. Create an AWS S3 Bucket

- Create an **S3 Bucket** with the default configuration.
- Name it `rancher-backup-(site)`.

### 4. Configure the Bucket Policy

- Insert the following policy inside the bucket, replacing `(site)` with the correct name:

```json
{
  "Version": "2012-10-17",
  "Id": "myPol",
  "Statement": [
      {
          "Sid": "Stmt130",
          "Effect": "Allow",
          "Principal": {
              "AWS": "arn:aws:iam::133428025519:user/rancher-backup-(site)"
          },
          "Action": "s3:*",
          "Resource": [
              "arn:aws:s3:::rancher-backup-(site)",
              "arn:aws:s3:::rancher-backup-(site)/*"
          ]
      }
  ]
}
```

## Deployment

After completing all the above steps, the bundle will be ready for deployment. 🚀
