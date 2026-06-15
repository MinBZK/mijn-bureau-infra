#!/usr/bin/env bash
# Usage: ./05-docs.sh
# Fixes Docs login and realtime collaboration. Idempotent — safe to re-run.
#
#   6b) The y-provider service sits on port 443 with a plain-HTTP backend, so
#       Traefik tries TLS against it and realtime collaboration 500s. Re-map the
#       ports so 443 (and 80) target the plain-HTTP container port 4444.
#   6c) Migrations run as the postgres superuser, so the app role `docs` has no
#       grants on the tables it needs and login 500s. Grant them (CloudNativePG;
#       superuser password is in the docs-cluster-rw secret).
set -euo pipefail

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "==> [6b] Re-mapping docs-y-provider service ports"
kubectl patch svc docs-y-provider -n mb-docs --type=merge -p '{
  "spec": {"ports": [
    {"name": "http", "port": 80, "targetPort": 4444, "protocol": "TCP"},
    {"name": "internal-443", "port": 443, "targetPort": 4444, "protocol": "TCP"}
  ]}}'

echo "==> [6c] Granting the docs role access to its tables"
PGPASS=$(kubectl get secret docs-cluster-rw -n mb-docs -o jsonpath='{.data.postgres-password}' | base64 -d)
kubectl exec -n mb-docs docs-cluster-rw-0 -- env PGPASSWORD="$PGPASS" psql -U postgres -h localhost -d docs -c "
  GRANT ALL ON ALL TABLES IN SCHEMA public TO docs;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO docs;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO docs;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO docs;"

echo ""
echo "Done. Docs login and realtime collaboration should now work."
