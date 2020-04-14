#!/bin/bash

set -x

ssh kueyen01.ls.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh kueyen01.ls.lsst.org -l jhoblitt_b sudo sh -c 'ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %'
ssh kueyen01.ls.lsst.org -l jhoblitt_b sudo rm -rf /dev/ceph-*
ssh kueyen01.ls.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdb
ssh kueyen01.ls.lsst.org -l jhoblitt_b sudo reboot

ssh kueyen02.ls.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh kueyen02.ls.lsst.org -l jhoblitt_b sudo sh -c 'ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %'
ssh kueyen02.ls.lsst.org -l jhoblitt_b sudo rm -rf /dev/ceph-*
ssh kueyen02.ls.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdb
ssh kueyen02.ls.lsst.org -l jhoblitt_b sudo reboot

ssh kueyen03.ls.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh kueyen03.ls.lsst.org -l jhoblitt_b sudo sh -c 'ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %'
ssh kueyen03.ls.lsst.org -l jhoblitt_b sudo rm -rf /dev/ceph-*
ssh kueyen03.ls.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdb
ssh kueyen03.ls.lsst.org -l jhoblitt_b sudo reboot

for n in $(seq 4 9);
do
    ssh "kueyen0${n}.ls.lsst.org" -l jhoblitt_b sudo rm -rf /var/lib/rook
done
