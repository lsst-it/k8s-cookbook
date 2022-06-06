#!/usr/bin/env bash

set -xe

SSH_USER='hreinking_b'
for i in {1..3}
do
  ssh -l "${SSH_USER}" orion0"${i}".cp.lsst.org 'sudo rm -rf /var/lib/rook'
  ssh -l "${SSH_USER}" orion0"${i}".cp.lsst.org 'ls /dev/mapper/ceph-* | xargs -I% -- echo /sbin/dmsetup remove %'
  ssh -l "${SSH_USER}" orion0"${i}".cp.lsst.org 'sudo rm -rf /dev/ceph-*'
  ssh -l "${SSH_USER}" orion0"${i}".cp.lsst.org 'sudo sgdisk --zap-all /dev/nvme0n1p4'
  ssh -l "${SSH_USER}" orion0"${i}".cp.lsst.org 'sudo dd if=/dev/zero of=/dev/nvme0n1p4 bs=1M count=100 oflag=direct,dsync'
  ssh -l "${SSH_USER}" orion0"${i}".cp.lsst.org 'sudo blockdev --rereadpt /dev/nvme0n1p4'
  # ssh -l "${SSH_USER}" "${i}" 'sudo reboot'
done