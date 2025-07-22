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

As of July 4th of 2025 the following is the expected output for both tools:

```bash

time=2025-07-04T21:03:43.047Z level=INFO source=net_snmp.go:174 msg="Loading MIBs" from=mibs
time=2025-07-04T21:03:43.132Z level=INFO source=main.go:57 msg="Generating config for module" module=if_mib
time=2025-07-04T21:03:43.152Z level=INFO source=main.go:75 msg="Generated metrics" module=if_mib metrics=40
time=2025-07-04T21:03:43.152Z level=INFO source=main.go:57 msg="Generating config for module" module=ip_mib
time=2025-07-04T21:03:43.156Z level=INFO source=main.go:75 msg="Generated metrics" module=ip_mib metrics=4
time=2025-07-04T21:03:43.156Z level=INFO source=main.go:57 msg="Generating config for module" module=raritan
time=2025-07-04T21:03:43.159Z level=INFO source=main.go:75 msg="Generated metrics" module=raritan metrics=86
time=2025-07-04T21:03:43.159Z level=INFO source=main.go:57 msg="Generating config for module" module=xups
time=2025-07-04T21:03:43.162Z level=INFO source=main.go:75 msg="Generated metrics" module=xups metrics=22
time=2025-07-04T21:03:43.162Z level=INFO source=main.go:57 msg="Generating config for module" module=schneider_pm5xxx
time=2025-07-04T21:03:43.166Z level=INFO source=main.go:75 msg="Generated metrics" module=schneider_pm5xxx metrics=36
time=2025-07-04T21:03:43.166Z level=INFO source=main.go:57 msg="Generating config for module" module=arista_tunnel
time=2025-07-04T21:03:43.169Z level=INFO source=main.go:75 msg="Generated metrics" module=arista_tunnel metrics=1
time=2025-07-04T21:03:43.169Z level=INFO source=main.go:57 msg="Generating config for module" module=network_base
time=2025-07-04T21:03:43.172Z level=INFO source=main.go:75 msg="Generated metrics" module=network_base metrics=14
time=2025-07-04T21:03:43.172Z level=INFO source=main.go:57 msg="Generating config for module" module=pfsense
time=2025-07-04T21:03:43.175Z level=INFO source=main.go:75 msg="Generated metrics" module=pfsense metrics=117
time=2025-07-04T21:03:43.207Z level=INFO source=main.go:100 msg="Config written" file=/opt/snmp.yml
```
