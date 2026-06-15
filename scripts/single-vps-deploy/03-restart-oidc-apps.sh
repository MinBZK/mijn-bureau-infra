#!/usr/bin/env bash
# Usage: ./03-restart-oidc-apps.sh
# Step 6h of the single-VPS quickstart: restart the OIDC apps.
#
# Each app fetches Keycloak's OIDC discovery document server-side at startup.
# The first attempt happens before step 5's networking is in place and before
# the TLS certificates are issued, so it fails — and that failure is sticky
# (you see "Could not reach the OpenID Connect provider" on login) until the
# pod restarts. Restart them now that the path works and the certs are valid.
#
# Run this only once `kubectl get certificate -A` shows every cert READY=True.
set -euo pipefail

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "==> [6h] Restarting OIDC apps so they re-read discovery"
kubectl rollout restart deploy/grist -n mb-grist
kubectl rollout restart deploy/docs-backend -n mb-docs
kubectl rollout restart deploy/nextcloud -n mb-nextcloud
kubectl rollout restart deploy/meet-backend -n mb-meet
kubectl rollout restart deploy/synapse -n mb-element

echo ""
echo "Restarts issued. Give the pods ~1-2 minutes, then retry logging in."
