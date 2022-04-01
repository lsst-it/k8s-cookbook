#!/bin/bash

set -x

declare -a DEV=("/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" "/dev/sde" "/dev/sdf" "/dev/sdg" "/dev/sdh" "/dev/sdi" "/dev/sdj")
declare -a SSH=("gaw01.ls.lsst.org" "gaw02.ls.lsst.org" "gaw03.ls.lsst.org" "gaw04.ls.lsst.org" "gaw05.ls.lsst.org")
declare -a SSH_USER='hreinking_b'
for f in "${SSH[@]}"
do
  for i in "${DEV[@]}"
  do
    ssh -l $SSH_USER $f 'sudo rm -rf /var/lib/rook'
    ssh -l $SSH_USER $f 'ls /dev/mapper/ceph-* | xargs -I% -- echo /sbin/dmsetup remove %'
    ssh -l $SSH_USER $f 'sudo rm -rf /dev/ceph-*'
    ssh -l $SSH_USER $f "sudo sgdisk --zap-all $i"
    ssh -l $SSH_USER $f "sudo dd if=/dev/zero of=$i bs=1M count=100 oflag=direct,dsync"
    ssh -l $SSH_USER $f "sudo blockdev --rereadpt $i"
  done
  # ssh -l $SSH_USER $f 'sudo reboot'
done