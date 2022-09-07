#!/bin/bash

exports=(
  jhome
  lsstdata
  project
  scratch
)

for e in "${exports[@]}"; do
  echo mkdir "$e"
  echo mount "${e}.nfs.ruka.dev.lsst.org:/${e}" "$e"
  echo umount "$e"
done
