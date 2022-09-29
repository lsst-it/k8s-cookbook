#!/bin/bash
cat << END | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cnpg-backup-secrets
  namespace: cloudnativepg
type: Opaque
stringData:
    ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
    SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
    password: ${SUPERUSER_PASSWORD}
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
      template:
        spec:
          containers:
          - name: cnpg-backup
            image: docker.io/cbarria/cnpg-backup:0.1
            imagePullPolicy: IfNotPresent
            env:
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: cnpg-backup-secrets
                  key: ACCESS_KEY_ID
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: cnpg-backup-secrets
                  key: SECRET_ACCESS_KEY
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: cnpg-backup-secrets
                  key: password
            - name: HOST
              value: "139.229.134.157"
          restartPolicy: OnFailure
END
