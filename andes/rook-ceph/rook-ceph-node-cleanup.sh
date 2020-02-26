#!/bin/bash

ssh andes01.cp.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh andes02.cp.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh andes03.cp.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook

ssh andes04.cp.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh andes04.cp.lsst.org -l jhoblitt_b sudo sh -c 'ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %'
ssh andes04.cp.lsst.org -l jhoblitt_b sudo rm -rf /dev/ceph-*
ssh andes04.cp.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/nvme0n1
ssh andes04.cp.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdb
ssh andes04.cp.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdc
ssh andes04.cp.lsst.org -l jhoblitt_b sudo reboot

ssh andes05.cp.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh andes05.cp.lsst.org -l jhoblitt_b sudo sh -c 'ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %'
ssh andes05.cp.lsst.org -l jhoblitt_b sudo rm -rf /dev/ceph-*
ssh andes05.cp.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/nvme0n1
ssh andes05.cp.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdb
ssh andes05.cp.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdc
ssh andes05.cp.lsst.org -l jhoblitt_b sudo reboot

ssh andes06.cp.lsst.org -l jhoblitt_b sudo rm -rf /var/lib/rook
ssh andes06.cp.lsst.org -l jhoblitt_b sudo sh -c 'ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %'
ssh andes06.cp.lsst.org -l jhoblitt_b sudo rm -rf /dev/ceph-*
ssh andes06.cp.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/nvme0n1
ssh andes06.cp.lsst.org -l jhoblitt_b sudo sgdisk --zap-all /dev/sdb
ssh andes06.cp.lsst.org -l jhoblitt_b sudo reboot
