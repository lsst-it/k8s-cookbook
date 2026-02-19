# Rubin's Ugly SNMP Generator

This repository provides a simple way to generate the `snmp.yml` configuration file using the `generator` binary based on definitions specified in `generator.yml`.

If new mibs are needed, they should be manually downloaded to the mibs directory.

Keep in mind that the `generator` binary is not provided and you should compile it locally to use it.

You can grab a copy of the sources from https://github.com/prometheus/snmp_exporter

## Directory Structure

- `generator.yml`: Input file containing the SNMP targets and configuration schema.
- `snmp.yml`: Output file automatically generated from `generator.yml`.
- `mibs/`: Directory containing all required MIB files used during generation.

## Usage

To generate the `snmp.yml` file, simply run:

```bash

generator generate --fail-on-parse-errors  --log.level=debug -m mibs

```

Now, if you are using Docker to generate the `snmp.yml` file, simply run:

```bash

docker run --rm -v $(pwd):/opt quay.io/prometheus/snmp-generator:latest generate

```

## Example

As of February 19th of 2026 the following is the expected output for both tools:

```bash
time=2026-02-19T19:45:42.817Z level=INFO source=net_snmp.go:174 msg="Loading MIBs" from=mibs
time=2026-02-19T19:45:42.903Z level=INFO source=main.go:57 msg="Generating config for module" module=if_mib
time=2026-02-19T19:45:42.914Z level=INFO source=main.go:75 msg="Generated metrics" module=if_mib metrics=40
time=2026-02-19T19:45:42.914Z level=INFO source=main.go:57 msg="Generating config for module" module=ip_mib
time=2026-02-19T19:45:42.916Z level=INFO source=main.go:75 msg="Generated metrics" module=ip_mib metrics=4
time=2026-02-19T19:45:42.916Z level=INFO source=main.go:57 msg="Generating config for module" module=raritan
time=2026-02-19T19:45:42.918Z level=INFO source=main.go:75 msg="Generated metrics" module=raritan metrics=86
time=2026-02-19T19:45:42.918Z level=INFO source=main.go:57 msg="Generating config for module" module=xups
time=2026-02-19T19:45:42.919Z level=INFO source=main.go:75 msg="Generated metrics" module=xups metrics=22
time=2026-02-19T19:45:42.919Z level=INFO source=main.go:57 msg="Generating config for module" module=schneider_pm5xxx
time=2026-02-19T19:45:42.921Z level=INFO source=main.go:75 msg="Generated metrics" module=schneider_pm5xxx metrics=36
time=2026-02-19T19:45:42.921Z level=INFO source=main.go:57 msg="Generating config for module" module=arista_tunnel
time=2026-02-19T19:45:42.922Z level=INFO source=main.go:75 msg="Generated metrics" module=arista_tunnel metrics=1
time=2026-02-19T19:45:42.922Z level=INFO source=main.go:57 msg="Generating config for module" module=pfsense
time=2026-02-19T19:45:42.924Z level=INFO source=main.go:75 msg="Generated metrics" module=pfsense metrics=117
time=2026-02-19T19:45:42.924Z level=INFO source=main.go:57 msg="Generating config for module" module=network_base
time=2026-02-19T19:45:42.926Z level=INFO source=main.go:75 msg="Generated metrics" module=network_base metrics=14
time=2026-02-19T19:45:42.926Z level=INFO source=main.go:57 msg="Generating config for module" module=mikrotik
time=2026-02-19T19:45:42.928Z level=INFO source=main.go:75 msg="Generated metrics" module=mikrotik metrics=110
time=2026-02-19T19:45:42.943Z level=INFO source=main.go:100 msg="Config written" file=/Users/csilva/Documents/Git/k8s-cookbook/rke2/ayekan/exporters/snmp-generator/snmp.yml
```
