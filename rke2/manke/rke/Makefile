HOSTNAME := $(shell hostname -f)
TARBALL = $(HOSTNAME).tar.gz

tarball:
	tar -czvf $(TARBALL) cluster.rkestate cluster.yml kube_config_cluster.yml
	chmod 600 $(TARBALL)

snapshot:
	rke etcd snapshot-save --config cluster.yml --name "$(hostname -f)-$(date -I --utc)-snapshot"
