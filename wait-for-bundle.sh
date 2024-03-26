#!/bin/sh

while true; do
  kubectl -n fleet-local wait --for=condition=ready bundle --timeout=25s
  kubectl -n fleet-local get bundle
  sleep 5
done
