#!/usr/bin/env bash

set -xe

SSH_USER='hreinking_b'
DEV=(a b c d e f g h i j)
SSH=(3)
for f in "${SSH[@]}"
do
  for i in "${DEV[@]}"
  do
    ssh -l $SSH_USER lukay0"${f}".cp.lsst.org 'sudo rm -rf /var/lib/rook'
    ssh -l $SSH_USER lukay0"${f}".cp.lsst.org 'ls /dev/mapper/ceph-* | xargs -I% -- echo /sbin/dmsetup remove %'
    ssh -l $SSH_USER lukay0"${f}".cp.lsst.org 'sudo rm -rf /dev/ceph-*'
    ssh -l $SSH_USER lukay0"${f}".cp.lsst.org "sudo sgdisk --zap-all /dev/sd${i}"
    ssh -l $SSH_USER lukay0"${f}".cp.lsst.org "sudo dd if=/dev/zero of=/dev/sd${i} bs=1M count=100 oflag=direct,dsync"
    ssh -l $SSH_USER lukay0"${f}".cp.lsst.org "sudo blockdev --rereadpt /dev/sd${i}"
  done
  # ssh -l $SSH_USER $f 'sudo reboot'
done