# mimir

## create rgw user

```bash
bash-4.4$ radosgw-admin user create --rgw-realm=o11y --rgw-zonegroup=o11y --rgw-zone=o11y --display-name="mimir role-user" --uid=mimir
2024-03-04T22:11:41.622+0000 7f82a1db0680  0 period (7e2fd4e3-a25a-4eab-b93f-36aace1a3bf7 does not have zone 3c4f8870-7c07-424d-ae34-7f826ad53125 configured
{
    "user_id": "mimir",
    "display_name": "mimir role-user",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "subusers": [],
    "keys": [
        {
            "user": "mimir",
            "access_key": "XXX",
            "secret_key": "XXX"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "default_storage_class": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}
```

Copy the generated credentials into a 1pass item named `s3.o11y.<site>.lsst.org-mimir`.
