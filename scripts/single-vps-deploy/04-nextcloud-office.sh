#!/usr/bin/env bash
# Usage: ./04-nextcloud-office.sh
# Warms the Collabora capabilities cache so Office files open in Nextcloud.
# Run after 03 (which restarts Nextcloud and sets the SSRF allowance).
# Safe to run repeatedly — every action is idempotent.
#
# Why: richdocuments caches the capabilities document it fetches from Collabora
# (collabora.DOMAIN/hosting/discovery). On a first deploy that fetch happens
# before step 5's networking exists, so an empty/failed response gets cached.
# Every file-open then calls ->xpath() on that cached `false` and 500s
# (richdocuments/lib/WOPI/Parser.php). Re-running the config fetch, now that the
# network path works, replaces the bad cache with a valid one.
set -euo pipefail

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "==> Waiting for Nextcloud to be ready"
kubectl rollout status deploy/nextcloud -n mb-nextcloud --timeout=300s

echo "==> Refreshing Collabora capabilities cache"
# activate-config re-fetches /hosting/discovery + /hosting/capabilities and
# rewrites the cache. Idempotent: running it again just re-fetches.
kubectl exec -n mb-nextcloud deploy/nextcloud -- php occ richdocuments:activate-config

echo ""
echo "Done. Office files (xlsx/docx/etc.) should now open in Nextcloud."
