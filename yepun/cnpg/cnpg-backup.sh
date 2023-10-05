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
  AWS_ACCESS_BUCKET: ${AWS_ACCESS_BUCKET}
  PGPASSWORD: ${SUPERUSER_PASSWORD}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cnpg-backups
  namespace: cloudnativepg
spec:
  concurrencyPolicy: Forbid
  schedule: "0 12,21 * * *" #9AM CLT - 6PM CLT
  jobTemplate:
    spec:
      ttlSecondsAfterFinished: 172800
      template:
        spec:
          activeDeadlineSeconds: 3600
          containers:
          - name: cnpg-backup
            image: docker.io/lsstit/cnpg-backup:0.3
            volumeMounts:
            - name: ephemeral
              mountPath: "/tmp"  
            imagePullPolicy: IfNotPresent
            envFrom:
            - secretRef:
                name: cnpg-backup-secrets
            env:
            - name: HOST
              value: "cnpg-loadbalancer.cloudnativepg.svc.cluster.local"
          volumes:
            - name: ephemeral
              ephemeral:
                volumeClaimTemplate:
                  spec:
                    accessModes: [ "ReadWriteOnce" ]
                    resources:
                      requests:
                        storage: 5Gi
          restartPolicy: OnFailure
END
