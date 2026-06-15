#!/usr/bin/env bash
# Usage: ./02-networking.sh [domain]
# Step 5 of the single-VPS quickstart: single-node networking workarounds.
# Run after 01-deploy.sh, once the apps have been deployed.
#
# The domain defaults to the value 01-deploy.sh saved in /etc/mijnbureau/domain;
# pass it as an argument only to override.
#
# Two unavoidable quirks of running everything on one box behind k3s Traefik:
#   a) Pods can't reach the cluster's own public IP (hairpin). Rewrite *.DOMAIN
#      via CoreDNS to the in-cluster Traefik service so traffic stays internal.
#   b) k3s Traefik listens on 8443, not 443; the bundled egress NetworkPolicies
#      only allow 443, so apps can't call each other's public hostnames. Allow 8443.
set -euo pipefail

DOMAIN="${1:-$(cat /etc/mijnbureau/domain 2>/dev/null || true)}"
if [ -z "${DOMAIN}" ]; then
  echo "No domain found. Pass it as an argument, or run 01-deploy.sh first." >&2
  exit 1
fi
# Escape dots for the CoreDNS regex (e.g. mb.example.com -> mb\.example\.com)
DOMAIN_ESCAPED="${DOMAIN//./\\.}"

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "==> [5a] CoreDNS hairpin rewrite for *.${DOMAIN}"
kubectl apply -f - <<YAML
apiVersion: v1
kind: ConfigMap
metadata: { name: coredns-custom, namespace: kube-system }
data:
  mb.override: |
    rewrite name regex (.*)\.${DOMAIN_ESCAPED} traefik.kube-system.svc.cluster.local answer auto
YAML
kubectl -n kube-system rollout restart deploy/coredns

echo "==> [5b] Egress NetworkPolicies allowing Traefik on 8443"
for ns in mb-keycloak mb-grist mb-element mb-collabora mb-nextcloud \
          mb-livekit mb-meet mb-docs mb-bureaublad mb-clamav mb-openproject; do
kubectl apply -f - <<YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: { name: allow-egress-traefik, namespace: ${ns} }
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
    - to: [{ podSelector: {} }]
    - to: [{ namespaceSelector: { matchLabels: { kubernetes.io/metadata.name: kube-system } } }]
      ports: [{ port: 8443, protocol: TCP }]
YAML
done

echo ""
echo "Networking workarounds applied. Wait for all certificates to be issued:"
echo "  kubectl get certificate -A"
echo "All must show READY=True before continuing to step 6 (post-deploy fixes)."
