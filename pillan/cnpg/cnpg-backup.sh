#!/bin/bash
cat << END | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cnpg-backup-secrets
  namespace: cloudnativepg
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
  AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
  PGPASSWORD: ${SUPERUSER_PASSWORD}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cnpg-backups
  namespace: cloudnativepg
spec:
  concurrencyPolicy: Forbid
  schedule: "0 12,21 * * *" #8AM CLT - 5PM CLT
  jobTemplate:
    spec:
      ttlSecondsAfterFinished: 172800
      template:
        spec:
          activeDeadlineSeconds: 3600
          containers:
          - name: cnpg-backup
            image: docker.io/cbarria/cnpg-backup:0.1
            imagePullPolicy: IfNotPresent
            envFrom:
            - secretRef:
                name: cnpg-backup-secrets
            env:
            - name: HOST
              value: "cnpg-loadbalancer.cloudnativepg.svc.cluster.local"
          restartPolicy: OnFailure
END
