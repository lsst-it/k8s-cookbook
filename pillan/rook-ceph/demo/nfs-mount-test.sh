#!/bin/bash

exports=(
  jhome
  lsstdata
  project
  scratch
)

for e in "${exports[@]}"; do
  echo mkdir "$e"
  echo mount "nfs-${e}.tu.lsst.org:/${e}" "$e"
  echo umount "$e"
done
