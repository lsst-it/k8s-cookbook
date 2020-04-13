#!/bin/bash

set -x

ssh antu01.ls.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh antu01.ls.lsst.org -l jhoblitt_b sudo sh -c 'ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %'
ssh antu01.ls.lsst.org -l jhoblitt_b sudo rm -rf /dev/ceph-*
ssh antu01.ls.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdb
ssh antu01.ls.lsst.org -l jhoblitt_b sudo reboot

ssh antu02.ls.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh antu02.ls.lsst.org -l jhoblitt_b sudo sh -c 'ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %'
ssh antu02.ls.lsst.org -l jhoblitt_b sudo rm -rf /dev/ceph-*
ssh antu02.ls.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdb
ssh antu02.ls.lsst.org -l jhoblitt_b sudo reboot

ssh antu03.ls.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh antu03.ls.lsst.org -l jhoblitt_b sudo sh -c 'ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %'
ssh antu03.ls.lsst.org -l jhoblitt_b sudo rm -rf /dev/ceph-*
ssh antu03.ls.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdb
ssh antu03.ls.lsst.org -l jhoblitt_b sudo reboot

for n in $(seq 4 9);
do
    ssh "antu0${n}.ls.lsst.org" -l jhoblitt_b sudo rm -rf /var/lib/rook
done
