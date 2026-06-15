#!/usr/bin/env bash
# Usage: ./06-grist.sh
# Fixes Grist file imports. Idempotent — safe to re-run.
#
#   6f) Grist runs two replicas with no session affinity, so a file upload lands
#       on one pod and the follow-up import request hits the other, which never
#       saw the upload ("Unknown upload"). Pin it to a single replica.
set -euo pipefail

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "==> [6f] Pinning Grist to a single replica"
kubectl patch hpa grist -n mb-grist -p '{"spec":{"minReplicas":1,"maxReplicas":1}}'
kubectl scale deploy grist -n mb-grist --replicas=1

echo ""
echo "Done. Grist file imports should now work."
