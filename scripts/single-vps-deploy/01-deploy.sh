#!/usr/bin/env bash
# Usage: ./deploy.sh <domain> <email> <master-password>
# Runs steps 1-4 of the MijnBureau Hetzner quickstart.
# Must be run as root on a fresh Ubuntu 24.04 server.
set -euo pipefail

DOMAIN="${1:?Usage: $0 <domain> <email> <master-password>}"
EMAIL="${2:?Usage: $0 <domain> <email> <master-password>}"
MASTER_PASSWORD="${3:?Usage: $0 <domain> <email> <master-password>}"

HELMFILE_V=1.1.7

echo "==> [1/4] Installing k3s, Helm, Helmfile"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -fsSL "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_V}/helmfile_${HELMFILE_V}_linux_amd64.tar.gz" \
  | tar -xz -C /usr/local/bin helmfile
helm plugin install https://github.com/databus23/helm-diff

echo "==> [2/4] Installing cert-manager and ClusterIssuer"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
kubectl -n cert-manager rollout status deploy/cert-manager-webhook --timeout=180s

kubectl apply -f - <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata: { name: letsencrypt-prod }
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${EMAIL}
    privateKeySecretRef: { name: letsencrypt-prod-account-key }
    solvers: [{ http01: { ingress: { class: traefik } } }]
YAML

echo "==> [3/4] Cloning repo and writing config"
cd /root
git clone https://github.com/MinBZK/mijn-bureau-infra
cd mijn-bureau-infra

cat > helmfile/environments/demo/mijnbureau.yaml.gotmpl <<YAML
---
global:
  domain: "${DOMAIN}"
  resourcesPreset: "none"
  resourcesPresetPerApp:
    collabora: "none"
    elementweb: "none"
    keycloak: "none"
    ollama: "none"
    synapse: "none"
    grist: "none"
    livekit: "none"
    meet: { backend: "none", frontend: "none" }
    nextcloud: "none"
    docs: { backend: "none", frontend: "none", celery: "none", yProvider: "none", docspec: "none" }
    drive: { backend: "none", frontend: "none" }
    conversations: { backend: "none", frontend: "none" }
    bureaublad: { backend: "none", frontend: "none" }
  tls:
    enabled: true
    selfSigned: false

cluster:
  routingMode: ingress
  ingress:
    type: traefik
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
  networking:
    podSubnet:
      - "10.42.0.0/16"
    serviceSubnet:
      - "10.43.0.0/16"

application:
  ollama:
    enabled: false
  keycloak:    { namespace: mb-keycloak }
  grist:       { namespace: mb-grist }
  element:     { namespace: mb-element }
  collabora:   { namespace: mb-collabora }
  nextcloud:   { namespace: mb-nextcloud }
  livekit:     { namespace: mb-livekit }
  meet:        { namespace: mb-meet }
  docs:        { namespace: mb-docs }
  bureaublad:  { namespace: mb-bureaublad }
  clamav:      { namespace: mb-clamav }
  openproject:
    enabled: true
    namespace: mb-openproject

authentication:
  oidc:
    issuer: "https://id.${DOMAIN}/realms/mijnbureau"
    authorization_endpoint: "https://id.${DOMAIN}/realms/mijnbureau/protocol/openid-connect/auth"
    token_endpoint: "https://id.${DOMAIN}/realms/mijnbureau/protocol/openid-connect/token"
    introspection_endpoint: "https://id.${DOMAIN}/realms/mijnbureau/protocol/openid-connect/token/introspect"
    userinfo_endpoint: "https://id.${DOMAIN}/realms/mijnbureau/protocol/openid-connect/userinfo"
    end_session_endpoint: "https://id.${DOMAIN}/realms/mijnbureau/protocol/openid-connect/logout"
    jwks_uri: "https://id.${DOMAIN}/realms/mijnbureau/protocol/openid-connect/certs"

security:
  openproject:
    containerSecurityContext:
      enabled: true
      allowPrivilegeEscalation: false
      capabilities:
        drop: [ALL]
      readOnlyRootFilesystem: false
      runAsNonRoot: true
      runAsUser: 1000
      runAsGroup: 1000

tls:
  openproject:
    - hosts:
        - openproject.${DOMAIN}
      secretName: openproject.${DOMAIN}-tls
YAML

echo "==> [4/4] Deploying (this takes 10-20 minutes)"
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export MIJNBUREAU_MASTER_PASSWORD="${MASTER_PASSWORD}"
export MIJNBUREAU_CREATE_NAMESPACES=true

yes | helmfile init || true
helmfile -e demo apply --skip-diff-on-install

echo ""
echo "Deploy complete. Continue with steps 5-6 of the guide (networking workarounds + post-deploy fixes)."
echo "Domain: ${DOMAIN}"
