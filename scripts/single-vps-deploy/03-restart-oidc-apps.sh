#!/usr/bin/env bash
# Usage: ./03-restart-oidc-apps.sh
# Steps 6d (Nextcloud SSRF allowance) + 6h (restart OIDC apps) of the
# single-VPS quickstart. Safe to run repeatedly — every action is idempotent.
#
# Why these two together:
#   - Step 5a rewrites *.DOMAIN via CoreDNS to the in-cluster Traefik ClusterIP,
#     which is a private IP. Nextcloud's SSRF guard refuses server-side requests
#     to private IPs unless allow_local_remote_servers=true, so OIDC discovery
#     fails ("Could not reach the provider") and login 404s. Set it first.
#   - Each app fetches Keycloak's OIDC discovery document at startup. The first
#     attempt happens before step 5's networking and the TLS certs are in place,
#     so it fails — and that failure is sticky until the pod restarts. Restart
#     them once the path works.
#
# Run this only once `kubectl get certificate -A` shows every cert READY=True.
set -euo pipefail

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "==> [6d] Allow Nextcloud to reach the CoreDNS-rewritten private IP (SSRF guard)"
# Idempotent: setting the value to true again is a no-op.
kubectl exec -n mb-nextcloud deploy/nextcloud -- \
  php occ config:system:set allow_local_remote_servers --value=true --type=boolean

echo "==> [6h] Restarting OIDC apps so they re-read discovery"
# Idempotent: rollout restart can be issued any number of times.
kubectl rollout restart deploy/grist -n mb-grist
kubectl rollout restart deploy/docs-backend -n mb-docs
kubectl rollout restart deploy/nextcloud -n mb-nextcloud
kubectl rollout restart deploy/meet-backend -n mb-meet
kubectl rollout restart deploy/synapse -n mb-element

echo ""
echo "Applied. Give the pods ~1-2 minutes, then retry logging in."
