#!/bin/bash

AWS_ACCESS_KEY_ID=$(kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-lfa-cp-dev -o jsonpath='{.data.AccessKey}' | base64 --decode)
export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$(kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-lfa-cp-dev -o jsonpath='{.data.SecretKey}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY

AWS_ACCESS_KEY_ID=$(kubectl -n rook-ceph get secret lfa-cp-dev -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$(kubectl -n rook-ceph get secret lfa-cp-dev -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY
