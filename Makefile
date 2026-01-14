VERSION := $(shell grep '^version:' Chart.yaml | awk '{print $$2}')

helm-package:
	rm -f supabase-*.tgz
	helm package . --version $(VERSION)

helm-push:
	helm push supabase-$(VERSION).tgz oci://registry-1.docker.io/00005555