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

## Example

As of May of 2025 the following is the output of this tool:

```bash
$ generator generate --fail-on-parse-errors  --log.level=debug -m mibs
time=2025-05-20T20:37:17.930Z level=INFO source=net_snmp.go:174 msg="Loading MIBs" from=mibs
time=2025-05-20T20:37:18.003Z level=INFO source=main.go:57 msg="Generating config for module" module=if_mib
time=2025-05-20T20:37:18.013Z level=INFO source=main.go:75 msg="Generated metrics" module=if_mib metrics=40
time=2025-05-20T20:37:18.013Z level=INFO source=main.go:57 msg="Generating config for module" module=ip_mib
time=2025-05-20T20:37:18.014Z level=INFO source=main.go:75 msg="Generated metrics" module=ip_mib metrics=4
time=2025-05-20T20:37:18.014Z level=INFO source=main.go:57 msg="Generating config for module" module=raritan
time=2025-05-20T20:37:18.016Z level=INFO source=main.go:75 msg="Generated metrics" module=raritan metrics=86
time=2025-05-20T20:37:18.016Z level=INFO source=main.go:57 msg="Generating config for module" module=xups
time=2025-05-20T20:37:18.018Z level=INFO source=main.go:75 msg="Generated metrics" module=xups metrics=22
time=2025-05-20T20:37:18.018Z level=INFO source=main.go:57 msg="Generating config for module" module=schneider_pm5xxx
time=2025-05-20T20:37:18.020Z level=INFO source=main.go:75 msg="Generated metrics" module=schneider_pm5xxx metrics=36
time=2025-05-20T20:37:18.020Z level=INFO source=main.go:57 msg="Generating config for module" module=arista_tunnel
time=2025-05-20T20:37:18.022Z level=INFO source=main.go:75 msg="Generated metrics" module=arista_tunnel metrics=1
time=2025-05-20T20:37:18.022Z level=INFO source=main.go:57 msg="Generating config for module" module=network_base
time=2025-05-20T20:37:18.023Z level=INFO source=main.go:75 msg="Generated metrics" module=network_base metrics=14
time=2025-05-20T20:37:18.036Z level=INFO source=main.go:100 msg="Config written" file=snmp.yml
$
```
