#/usr/bin/env bash

set -eux

parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart primary 0% 30%
parted /dev/sdb mkpart primary 30% 60%
parted /dev/sdb mkpart primary 60% 90%