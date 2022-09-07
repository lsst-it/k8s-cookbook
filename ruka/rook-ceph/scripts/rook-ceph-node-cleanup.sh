#!/bin/bash

set -x

DEV1=/dev/sda
DEV2=/dev/sdb
SSH_CMD='clush -g ruka'

${SSH_CMD} sudo rm -rf /var/lib/rook
${SSH_CMD} 'ls /dev/mapper/ceph-* | xargs -I% -- echo /sbin/dmsetup remove %'
${SSH_CMD} sudo rm -rf /dev/ceph-*
${SSH_CMD} sudo sgdisk --zap-all "$DEV1"
${SSH_CMD} sudo sgdisk --zap-all "$DEV2"
${SSH_CMD} sudo dd if=/dev/zero "of=${DEV1}" bs=1M count=100 oflag=direct,dsync
${SSH_CMD} sudo dd if=/dev/zero "of=${DEV2}" bs=1M count=100 oflag=direct,dsync
${SSH_CMD} sudo blockdev --rereadpt "$DEV1"
${SSH_CMD} sudo blockdev --rereadpt "$DEV2"
${SSH_CMD} lsblk
# sometimes dm devices aren't cleaned up for unknown reason(s)
${SSH_CMD} sudo reboot
