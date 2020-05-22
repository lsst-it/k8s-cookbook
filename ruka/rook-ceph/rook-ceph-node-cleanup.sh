#!/bin/bash

set -x

SSH_USER=jhoblitt_b

for n in $(seq 1 3);
do
    HOST="ruka0${n}.ls.lsst.org"
    SSH_CMD="ssh ${HOST} -l ${SSH_USER}"

    ${SSH_CMD} sudo rm -rf /var/lib/rook
    ${SSH_CMD} sudo sh -c 'ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %'
    ${SSH_CMD} sudo rm -rf /dev/ceph-*
    ${SSH_CMD} sudo sgdisk --zap-all /dev/sdb
    ${SSH_CMD} sudo dd if=/dev/zero of=/dev/sdb bs=1M count=100 oflag=direct,dsync
    ${SSH_CMD} sudo blockdev --rereadpt /dev/sdb
    # reboot still seems to be required to clear the disk label
    # DO NOT reboot all controlplane/etcd hosts at the same time
    #${SSH_CMD} sudo reboot
done
