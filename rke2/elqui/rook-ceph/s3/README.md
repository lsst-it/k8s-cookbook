# semi-manual bucket notification configuration

## topic creation

Insert the kafka crednetials from the 1pass item named `kafka-bucket-notifications` in the `elqui.cp` vault in http basic auth format.

```bash
k apply --server-side -f bucket-rubinobs-raw-latiss-cephbuckettopic.yaml
k apply --server-side -f bucket-rubinobs-raw-comcam-cephbuckettopic.yaml
k apply --server-side -f bucket-rubinobs-raw-lsstcam-cephbuckettopic.yaml
```
