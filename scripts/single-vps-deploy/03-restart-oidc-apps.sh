#!/usr/bin/env bash
# Usage: ./03-restart-oidc-apps.sh
# Nextcloud networking config + restart of the OIDC apps. Safe to run
# repeatedly — every action is idempotent.
#
# Why these together:
#   - Step 5a rewrites *.DOMAIN via CoreDNS to the in-cluster Traefik ClusterIP,
#     which is a private IP. Nextcloud's SSRF guard refuses server-side requests
#     to private IPs unless allow_local_remote_servers=true, so OIDC discovery
#     fails ("Could not reach the provider") and login 404s. Set it first.
#   - Traefik runs in the pod subnet (10.42.0.0/16) but Nextcloud's
#     trusted_proxies only lists the service subnet (10.43.0.0/16), so Nextcloud
#     sees every request as coming from one internal IP: all users share one
#     rate-limit/throttle bucket ("Too many requests") and client IPs are logged
#     wrong. Add the pod subnet.
#   - Each app fetches Keycloak's OIDC discovery document at startup. The first
#     attempt happens before step 5's networking and the TLS certs are in place,
#     so it fails — and that failure is sticky until the pod restarts. Restart
#     them once the path works (this also makes Nextcloud pick up the config above).
#
# Run this only once `kubectl get certificate -A` shows every cert READY=True.
set -euo pipefail

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "==> [6d] Allow Nextcloud to reach the CoreDNS-rewritten private IP (SSRF guard)"
# Idempotent: setting the value to true again is a no-op.
kubectl exec -n mb-nextcloud deploy/nextcloud -- \
  php occ config:system:set allow_local_remote_servers --value=true --type=boolean

echo "==> Add the Traefik pod subnet to Nextcloud trusted_proxies"
# Idempotent: index 0 is the chart's service subnet; we set index 1 to the pod
# subnet. Re-running writes the same value.
kubectl exec -n mb-nextcloud deploy/nextcloud -- \
  php occ config:system:set trusted_proxies 1 --value=10.42.0.0/16

echo "==> [6h] Restarting OIDC apps so they re-read discovery"
# Idempotent: rollout restart can be issued any number of times.
kubectl rollout restart deploy/grist -n mb-grist
kubectl rollout restart deploy/docs-backend -n mb-docs
kubectl rollout restart deploy/nextcloud -n mb-nextcloud
kubectl rollout restart deploy/meet-backend -n mb-meet
kubectl rollout restart deploy/synapse -n mb-element

echo ""
echo "Applied. Give the pods ~1-2 minutes, then retry logging in."
