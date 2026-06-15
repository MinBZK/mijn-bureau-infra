#!/usr/bin/env bash
# Usage: ./07-session-lifetimes.sh [domain]
# Step 7 (optional): stretch Keycloak's token/session lifetimes.
# Idempotent — re-running just sets the same realm values again.
#
# Out of the box Keycloak issues 5-minute access tokens with a 30-minute idle
# timeout, so you re-authenticate constantly across every app. This widens them
# to a 30-minute access token, 7-day idle timeout, 30-day max session, plus
# "remember me".
#
# Domain defaults to the value 01-deploy.sh saved in /etc/mijnbureau/domain;
# pass it as an argument only to override.
set -euo pipefail

DOMAIN="${1:-$(cat /etc/mijnbureau/domain 2>/dev/null || true)}"
if [ -z "${DOMAIN}" ]; then
  echo "No domain found. Pass it as an argument, or run 01-deploy.sh first." >&2
  exit 1
fi

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "==> [7] Widening Keycloak session lifetimes on the mijnbureau realm"
KC_PASS=$(kubectl get secret keycloak-keycloak -n mb-keycloak -o jsonpath='{.data.admin-password}' | base64 -d)
TOKEN=$(curl -s "https://id.${DOMAIN}/realms/master/protocol/openid-connect/token" \
  -d grant_type=password -d client_id=admin-cli -d username=admin -d "password=${KC_PASS}" \
  | python3 -c 'import sys,json;print(json.load(sys.stdin)["access_token"])')
curl -s -X PUT "https://id.${DOMAIN}/admin/realms/mijnbureau" \
  -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" \
  -d '{"accessTokenLifespan":1800,"ssoSessionIdleTimeout":604800,"ssoSessionMaxLifespan":2592000,"rememberMe":true}'

echo ""
echo "Done. New sessions use the longer lifetimes (existing sessions keep their old ones)."
