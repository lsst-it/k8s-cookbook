#!/bin/bash

set -x

DEV=/dev/nvme1n1
SSH_CMD='clush -g pillan'

${SSH_CMD} sudo /bin/rm -rf /var/lib/rook
${SSH_CMD} 'ls /dev/mapper/ceph-* | xargs -I% -- echo /sbin/dmsetup remove %'
${SSH_CMD} sudo /bin/rm -rf /dev/ceph-*
${SSH_CMD} sudo /sbin/sgdisk --zap-all "$DEV"
