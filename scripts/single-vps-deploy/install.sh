#!/usr/bin/env bash
# Usage: ./install.sh <domain> <email> <master-password>
# One-shot: blank Ubuntu 24.04 box -> fully working MijnBureau single-VPS setup.
#
# Runs every step in order, waiting for TLS certificates to be issued between
# the networking step and the app fixes (the OIDC apps need valid certs to read
# discovery). Every sub-script is idempotent, so this is safe to re-run.
#
# Sub-scripts are fetched from the same repo/branch as this one by default;
# override with BASE_URL=... if you host them elsewhere.
set -euo pipefail

DOMAIN="${1:?Usage: $0 <domain> <email> <master-password>}"
EMAIL="${2:?Usage: $0 <domain> <email> <master-password>}"
MASTER_PASSWORD="${3:?Usage: $0 <domain> <email> <master-password>}"

BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/ritza-co/mijn-bureau-infra/ritza/docs-single-vps-k3s-guide/scripts/single-vps-deploy}"

run_step() {
  # run_step <script> [args...]
  local script="$1"; shift
  echo ""
  echo "############################################################"
  echo "# ${script}"
  echo "############################################################"
  curl -fsSL "${BASE_URL}/${script}" | bash -s -- "$@"
}

wait_for_certs() {
  echo ""
  echo "==> Waiting for all TLS certificates to be issued (can take a few minutes)"
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  # Let cert-manager create the Certificate resources for every ingress first.
  sleep 30
  local prev=-1 stable=0 total ready
  while :; do
    total=$(kubectl get certificate -A --no-headers 2>/dev/null | wc -l | tr -d ' ')
    ready=$(kubectl get certificate -A --no-headers 2>/dev/null | awk '$3=="True"' | wc -l | tr -d ' ')
    echo "  certificates ready: ${ready}/${total}"
    # Break only when all certs are ready AND the count has been stable for two
    # consecutive checks, so we don't exit early before every cert is created.
    if [ "${total}" -gt 0 ] && [ "${total}" -eq "${ready}" ]; then
      if [ "${total}" -eq "${prev}" ]; then
        stable=$((stable + 1))
        [ "${stable}" -ge 2 ] && break
      else
        stable=0
      fi
    else
      stable=0
    fi
    prev="${total}"
    sleep 15
  done
  echo "  all ${total} certificates ready"
}

# 1-4: k3s, cert-manager, config, helmfile deploy
run_step 01-deploy.sh "${DOMAIN}" "${EMAIL}" "${MASTER_PASSWORD}"

# 5: single-node networking workarounds
run_step 02-networking.sh "${DOMAIN}"

# Certs must be issued before the OIDC apps can read discovery.
wait_for_certs

# 6d/6h: Nextcloud SSRF + trusted_proxies, restart OIDC apps
run_step 03-restart-oidc-apps.sh

# Warm the Collabora capabilities cache (waits for Nextcloud internally)
run_step 04-nextcloud-office.sh

# Docs (login + realtime) and Grist (file imports)
run_step 05-docs.sh
run_step 06-grist.sh

# 7: longer session lifetimes (optional but recommended)
run_step 07-session-lifetimes.sh "${DOMAIN}"

echo ""
echo "############################################################"
echo "# Done. MijnBureau should be fully working at:"
echo "#   https://bureaublad.${DOMAIN}"
echo "############################################################"
