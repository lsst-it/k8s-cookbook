# Copyright 2018 The Prometheus Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SOURCE: https://raw.githubusercontent.com/prometheus/snmp_exporter/main/generator/Makefile

MIBDIR   := mibs
MIB_PATH := 'mibs'

CURL_OPTS ?= -L -sS --retry 3 --retry-delay 3 --fail -A "Prometheus SNMP generator Makefile"

APC_URL             := https://download.schneider-electric.com/files?p_Doc_Ref=APC_POWERNETMIB_EN&p_enDocType=Firmware&p_File_Name=powernet457.mib
ARISTA_URL          := https://www.arista.com/assets/data/docs/MIBS
CISCO_URL           := https://raw.githubusercontent.com/cisco/cisco-mibs/05dbf50226f7df5f52fd2dd1a9c17759273fa0d0/v2/
CISCO_URL2           := https://raw.githubusercontent.com/cisco/cisco-mibs/05dbf50226f7df5f52fd2dd1a9c17759273fa0d0/v1/
DELL_URL            := https://dl.dell.com/FOLDER11196144M/1/Dell-OM-MIBS-11010_A00.zip
IANA_CHARSET_URL    := https://www.iana.org/assignments/ianacharset-mib/ianacharset-mib
IANA_IFTYPE_URL     := https://www.iana.org/assignments/ianaiftype-mib/ianaiftype-mib
IANA_PRINTER_URL    := https://www.iana.org/assignments/ianaprinter-mib/ianaprinter-mib
VRRP_URL            := https://raw.githubusercontent.com/acassen/keepalived/v2.2.8/doc/VRRP-MIB.txt
VRRPV3_URL          := https://raw.githubusercontent.com/acassen/keepalived/v2.2.8/doc/VRRPv3-MIB.txt
MIKROTIK_URL        := 'https://box.mikrotik.com/f/a41daf63d0c14347a088/?dl=1'
NEC_URL             := https://jpn.nec.com/univerge/ix/Manual/MIB
NET_SNMP_URL        := https://raw.githubusercontent.com/net-snmp/net-snmp/refs/heads/master/mibs/
UBNT_AIROS_URL      := https://dl.ubnt.com/firmwares/airos-ubnt-mib/ubnt-mib.zip
UBNT_AIRFIBER_URL   := https://dl.ubnt.com/firmwares/airfiber5X/v4.1.0/UBNT-MIB.txt
UBNT_DL_URL         := http://dl.ubnt-ut.com/snmp
RARITAN_URL         := https://cdn.raritan.com/download/PX/v1.5.20/PDU-MIB.txt
RARITAN2_URL        := https://cdn1.raritan.com/download/src-g2/4.0.20/PDU2_MIB_4.0.20_49038.txt
LIEBERT_URL         := https://www.vertiv.com/globalassets/documents/software/monitoring/lgpmib-win_rev16_299461_0.zip
XUPS_URL            := https://mibbrowser.online/mibs/XUPS-MIB.mib
SCHNEIDER_PM5XX_URL := https://ckm-content.se.com/ckmContent/sfc/servlet.shepherd/document/download/0691H00000GYnUPQA1

.DEFAULT: all

.PHONY: all
all: mibs

clean:
	rm -rvf \
		$(MIBDIR)/* \
		$(MIBDIR)/.cisco_v2 \
		$(MIBDIR)/.dell \
		$(MIBDIR)/.net-snmp 

generate: generator mibs
	MIBDIRS=$(MIB_PATH) generator --fail-on-parse-errors generate

create_dir:
	mkdir -p $(MIBDIR)

parse_errors: generator mibs
	MIBDIRS=$(MIB_PATH) generator --fail-on-parse-errors parse_errors

mibs: create_dir \
  $(MIBDIR)/apc-powernet-mib \
  $(MIBDIR)/XUPS-MIB.mib \
  $(MIBDIR)/SchneiderPM55xx_V01_13.mib \
  $(MIBDIR)/ARISTA-ENTITY-SENSOR-MIB \
  $(MIBDIR)/ARISTA-SMI-MIB \
  $(MIBDIR)/ARISTA-SW-IP-FORWARDING-MIB \
  $(MIBDIR)/ARISTA-TUNNEL-MIB \
  $(MIBDIR)/.cisco_v2 \
  $(MIBDIR)/CISCO-OLD-CPU-MIB \
  $(MIBDIR)/.dell \
  $(MIBDIR)/ENTITY-MIB \
  $(MIBDIR)/ENTITY-SENSOR-MIB \
  $(MIBDIR)/ENTITY-STATE-MIB \
  $(MIBDIR)/ENTITY-STATE-TC-MIB \
  $(MIBDIR)/IANA-CHARSET-MIB.txt \
  $(MIBDIR)/IANA-IFTYPE-MIB.txt \
  $(MIBDIR)/IANA-PRINTER-MIB.txt \
  $(MIBDIR)/VRRP-MIB \
  $(MIBDIR)/VRRPv3-MIB \
  $(MIBDIR)/MIKROTIK-MIB \
  $(MIBDIR)/.net-snmp \
  $(MIBDIR)/UBNT-UniFi-MIB \
  $(MIBDIR)/UBNT-AirFiber-MIB \
  $(MIBDIR)/UBNT-AirMAX-MIB.txt \
  $(MIBDIR)/PDU-MIB.txt \
  $(MIBDIR)/PDU2-MIB.txt \
  $(MIBDIR)/LIEBERT_GP_PDU.MIB \

$(MIBDIR)/apc-powernet-mib:
	@echo ">> Downloading apc-powernet-mib"
	@curl $(CURL_OPTS) -o $(MIBDIR)/apc-powernet-mib "$(APC_URL)"
	# Workaround to make DisplayString available (#867)
	@sed -i.bak -E 's/(DisplayString[[:space:]]*FROM )RFC1213-MIB/\1SNMPv2-TC/' $(MIBDIR)/apc-powernet-mib
	@rm $(MIBDIR)/apc-powernet-mib.bak

$(MIBDIR)/ARISTA-ENTITY-SENSOR-MIB:
	@echo ">> Downloading ARISTA-ENTITY-SENSOR-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/ARISTA-ENTITY-SENSOR-MIB "$(ARISTA_URL)/ARISTA-ENTITY-SENSOR-MIB.txt"

$(MIBDIR)/ARISTA-SMI-MIB:
	@echo ">> Downloading ARISTA-SMI-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/ARISTA-SMI-MIB "$(ARISTA_URL)/ARISTA-SMI-MIB.txt"

$(MIBDIR)/ARISTA-SW-IP-FORWARDING-MIB:
	@echo ">> Downloading ARISTA-SW-IP-FORWARDING-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/ARISTA-SW-IP-FORWARDING-MIB "$(ARISTA_URL)/ARISTA-SW-IP-FORWARDING-MIB.txt"

$(MIBDIR)/ARISTA-TUNNEL-MIB:
	@echo ">> Downloading ARISTA-TUNNEL-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/ARISTA-TUNNEL-MIB "$(ARISTA_URL)/ARISTA-TUNNEL-MIB.txt"

$(MIBDIR)/.cisco_v2:
	@echo ">> Downloading Cisco MIBS"
	@curl $(CURL_OPTS) -o $(MIBDIR)/CISCO-MEMORY-POOL-MIB "$(CISCO_URL)/CISCO-MEMORY-POOL-MIB.my"
	@curl $(CURL_OPTS) -o $(MIBDIR)/CISCO-PROCESS-MIB "$(CISCO_URL)/CISCO-PROCESS-MIB.my"
	@curl $(CURL_OPTS) -o $(MIBDIR)/CISCO-ENTITY-SENSOR-MIB "$(CISCO_URL)/CISCO-ENTITY-SENSOR-MIB.my"
	@curl $(CURL_OPTS) -o $(MIBDIR)/CISCO-QOS-PIB-MIB "$(CISCO_URL)/CISCO-QOS-PIB-MIB.my"
	@curl $(CURL_OPTS) -o $(MIBDIR)/CISCO-SMI "$(CISCO_URL)/CISCO-SMI.my"
	@curl $(CURL_OPTS) -o $(MIBDIR)/CISCO-TC "$(CISCO_URL)/CISCO-TC.my"
	
$(MIBDIR)/CISCO-OLD-CPU-MIB:
	@echo ">> Downloading Cisco CISCO-OLD-CPU-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/CISCO-OLD-CPU-MIB "$(CISCO_URL2)/OLD-CISCO-CPU-MIB.my"	

$(MIBDIR)/.dell:
	$(eval TMP := $(shell mktemp))
	@echo ">> Downloading dell to $(TMP)"
	@curl $(CURL_OPTS) -H "User-Agent: snmp_exporter" -o $(TMP) $(DELL_URL)
	@unzip -j -d $(MIBDIR) $(TMP) support/station/mibs/iDRAC-*.mib
	@sed -i '$ d' $(MIBDIR)/iDRAC-SMIv1.mib
	@rm -v $(TMP)
	@touch $(MIBDIR)/.dell

$(MIBDIR)/ENTITY-MIB:
	@echo ">> Downloading Cisco ENTITY-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/ENTITY-MIB "$(CISCO_URL)/ENTITY-MIB.my"

$(MIBDIR)/ENTITY-SENSOR-MIB:
	@echo ">> Downloading Cisco ENTITY-SENSOR-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/ENTITY-SENSOR-MIB "$(CISCO_URL)/ENTITY-SENSOR-MIB.my"

$(MIBDIR)/ENTITY-STATE-MIB:
	@echo ">> Downloading Cisco ENTITY-STATE-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/ENTITY-STATE-MIB "$(CISCO_URL)/ENTITY-STATE-MIB.my"

$(MIBDIR)/ENTITY-STATE-TC-MIB:
	@echo ">> Downloading Cisco ENTITY-STATE-TC-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/ENTITY-STATE-TC-MIB "$(CISCO_URL)/ENTITY-STATE-TC-MIB.my"

$(MIBDIR)/IANA-CHARSET-MIB.txt:
	@echo ">> Downloading IANA charset MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/IANA-CHARSET-MIB.txt $(IANA_CHARSET_URL)

$(MIBDIR)/IANA-IFTYPE-MIB.txt:
	@echo ">> Downloading IANA ifType MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/IANA-IFTYPE-MIB.txt $(IANA_IFTYPE_URL)

$(MIBDIR)/IANA-PRINTER-MIB.txt:
	@echo ">> Downloading IANA printer MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/IANA-PRINTER-MIB.txt $(IANA_PRINTER_URL)

$(MIBDIR)/VRRP-MIB:
	@echo ">> Downloading VRRP-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/VRRP-MIB $(VRRP_URL)

$(MIBDIR)/VRRPv3-MIB:
	@echo ">> Downloading VRRPv3-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/VRRPv3-MIB $(VRRPV3_URL)

$(MIBDIR)/MIKROTIK-MIB:
	@echo ">> Downloading MIKROTIK-MIB"
	@curl $(CURL_OPTS) -L -o $(MIBDIR)/MIKROTIK-MIB $(MIKROTIK_URL)

$(MIBDIR)/.net-snmp:
	@echo ">> Downloading NET-SNMP mibs"
	@curl $(CURL_OPTS) -o $(MIBDIR)/HCNUM-TC $(NET_SNMP_URL)/HCNUM-TC.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/HOST-RESOURCES-MIB $(NET_SNMP_URL)/HOST-RESOURCES-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/IF-MIB $(NET_SNMP_URL)/IF-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/IP-MIB $(NET_SNMP_URL)/IP-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/INET-ADDRESS-MIB $(NET_SNMP_URL)/INET-ADDRESS-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/IPV6-TC $(NET_SNMP_URL)/IPV6-TC.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/NET-SNMP-MIB $(NET_SNMP_URL)/NET-SNMP-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/NET-SNMP-TC $(NET_SNMP_URL)/NET-SNMP-TC.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/SNMP-FRAMEWORK-MIB $(NET_SNMP_URL)/SNMP-FRAMEWORK-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/SNMPv2-MIB $(NET_SNMP_URL)/SNMPv2-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/SNMPv2-SMI $(NET_SNMP_URL)/SNMPv2-SMI.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/SNMPv2-TC $(NET_SNMP_URL)/SNMPv2-TC.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/UCD-SNMP-MIB $(NET_SNMP_URL)/UCD-SNMP-MIB.txt
	@touch $(MIBDIR)/.net-snmp

$(MIBDIR)/UBNT-UniFi-MIB:
	@echo ">> Downloading UBNT-UniFi-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/UBNT-UniFi-MIB "$(UBNT_DL_URL)/UBNT-UniFi-MIB"

$(MIBDIR)/UBNT-AirFiber-MIB:
	@echo ">> Downloading UBNT-AirFiber-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/UBNT-AirFiber-MIB $(UBNT_AIRFIBER_URL)

$(MIBDIR)/UBNT-AirMAX-MIB.txt:
	$(eval TMP := $(shell mktemp))
	@echo ">> Downloading ubnt-airos to $(TMP)"
	@curl $(CURL_OPTS) -o $(TMP) $(UBNT_AIROS_URL)
	@unzip -j -d $(MIBDIR) $(TMP) UBNT-AirMAX-MIB.txt
	@rm -v $(TMP)

$(MIBDIR)/PDU-MIB.txt:
	@echo ">> Downloading Raritan PDU-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/PDU-MIB.txt "$(RARITAN_URL)"

$(MIBDIR)/PDU2-MIB.txt:
	@echo ">> Downloading Raritan PDU2-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/PDU2-MIB.txt "$(RARITAN2_URL)"

$(MIBDIR)/LIEBERT_GP_PDU.MIB:
	$(eval TMP := $(shell mktemp))
	@echo ">> Downloading LIEBERT_GP_PDU.MIB to $(TMP)"
	@curl $(CURL_OPTS) -o $(TMP) $(LIEBERT_URL)
	@unzip -j -d $(MIBDIR) $(TMP) LIEBERT_GP_PDU.MIB LIEBERT_GP_REG.MIB
	@rm -v $(TMP)

$(MIBDIR)/XUPS-MIB.mib:
	@echo ">> Downloading XUPS-MIB.mib"
	@curl $(CURL_OPTS) -o $(MIBDIR)/XUPS-MIB.mib "$(XUPS_URL)"

$(MIBDIR)/SchneiderPM55xx_V01_13.mib:
	$(eval TMP := $(shell mktemp))
	@echo ">> Downloading SchneiderPM55xx_V01_13.mib to $(TMP)"
	@curl $(CURL_OPTS) -o $(TMP) $(SCHNEIDER_PM5XX_URL)
	@unzip -j -d $(MIBDIR) $(TMP) PM5560_PM5563_v2.1.0/SchneiderPM55xx_V01_13.mib
	@sed -i 's/_//g' $(MIBDIR)/SchneiderPM55xx_V01_13.mib
	@rm -v $(TMP)
