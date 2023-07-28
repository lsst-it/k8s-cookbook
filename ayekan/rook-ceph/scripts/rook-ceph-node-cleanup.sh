#!/bin/bash

set -x

DEV=/dev/nvme1n1
SSH_CMD='clush -g ayekan'

${SSH_CMD} sudo rm -rf /var/lib/rook
${SSH_CMD} 'ls /dev/mapper/ceph-* | xargs -I% -- echo /sbin/dmsetup remove %'
${SSH_CMD} sudo rm -rf /dev/ceph-*
${SSH_CMD} sudo sgdisk --zap-all "$DEV"
${SSH_CMD} sudo dd if=/dev/zero "of=${DEV}" bs=1M count=100 oflag=direct,dsync
${SSH_CMD} sudo blockdev --rereadpt "$DEV"
${SSH_CMD} lsblk
# sometimes dm devices aren't cleaned up for unknown reason(s)
${SSH_CMD} sudo reboot
