#!/bin/bash

set -x

DEVS=(
  nvme0n1
)

HOSTS=(
  kueyen03
  kueyen02
  kueyen01
)

for H in "${HOSTS[@]}"; do
  SSH_CMD="ssh ${H}"

  ${SSH_CMD} sudo rm -rf /var/lib/rook
  ${SSH_CMD} 'ls /dev/mapper/ceph-* | xargs -I% -- echo /sbin/dmsetup remove %'
  ${SSH_CMD} sudo rm -rf /dev/ceph-*
  for D in "${DEVS[@]}"; do
    ${SSH_CMD} sudo sgdisk --zap-all "/dev/${D}"
    ${SSH_CMD} sudo dd if=/dev/zero "of=/dev/${D}" bs=1M count=100 oflag=direct,dsync
    ${SSH_CMD} sudo blockdev --rereadpt "/dev/${D}"
  done
  ${SSH_CMD} lsblk
  # sometimes dm devices aren't cleaned up for unknown reason(s)
  ${SSH_CMD} sudo reboot
done
