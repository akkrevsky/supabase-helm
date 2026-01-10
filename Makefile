helm-package:
	helm package .
helm-push:
	helm push supabase-1.0.1.tgz oci://registry-1.docker.io/00005555