---
sidebar_position: 6
description: Deploy the full MijnBureau suite on a single Linux server using k3s and Helmfile, with real TLS certificates and working SSO, in roughly 30–45 minutes.
---

# Get started on a single VPS with K3s

This gets the full MijnBureau suite
(Keycloak SSO, Nextcloud + Collabora office, Grist, Docs, Element chat, Meet video,
OpenProject, Bureaublad dashboard) running on **one Linux server** with real TLS
certificates and working single sign-on, in roughly 30–45 minutes.

:::warning Demo/evaluation only
Single node, no backups, no disaster recovery, all datastores in-cluster, secrets
derived from one master password. Don't put real data on it without adding backups
(Velero or similar) and rotating every secret.
:::

## Prerequisites

- A server with **≥12 vCPU and ≥48 GiB RAM**, Ubuntu 24.04, root access.
  (Tested on a Hetzner AX41-NVMe. Less RAM may work since resource requests are
  disabled, but Nextcloud + Synapse + OpenProject together are hungry.)
- A **wildcard DNS record**: `*.DOMAIN` → your server's IPv4.
  (~18 hostnames are needed; the wildcard covers all of them. Remove any AAAA record
  unless your box serves IPv6.)
- Nothing else listening on ports 80/443.

Throughout, replace `DOMAIN` with your domain (e.g. `mb.example.com`) and pick a
strong `MASTER_PASSWORD` — every app secret is derived from it.

## 1. k3s + Helm + Helmfile

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
HELMFILE_V=1.1.7
curl -fsSL "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_V}/helmfile_${HELMFILE_V}_linux_amd64.tar.gz" \
  | tar -xz -C /usr/local/bin helmfile
helm plugin install https://github.com/databus23/helm-diff
```

## 2. cert-manager + Let's Encrypt

Real certificates are **required**, not nice-to-have: with self-signed certs the
server-side OIDC calls between apps fail and SSO breaks.

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
kubectl -n cert-manager rollout status deploy/cert-manager-webhook --timeout=180s

kubectl apply -f - <<'YAML'
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata: { name: letsencrypt-prod }
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: you@example.com            # <- change
    privateKeySecretRef: { name: letsencrypt-prod-account-key }
    solvers: [{ http01: { ingress: { class: traefik } } }]
YAML
```

## 3. Get MijnBureau and configure the demo environment

```bash
git clone https://github.com/MinBZK/mijn-bureau-infra && cd mijn-bureau-infra
```

Overwrite `helmfile/environments/demo/mijnbureau.yaml.gotmpl` with the following
(then `sed -i 's/DOMAIN/your.actual.domain/g'` it):

```yaml
---
global:
  domain: "DOMAIN"

  # The demo "small" preset requests ~22 CPU cores and will never schedule on
  # one box. "none" drops requests/limits so apps share whatever exists.
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
    selfSigned: false        # real certs via cert-manager; self-signed breaks SSO

cluster:
  routingMode: ingress
  ingress:
    type: traefik
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
  # k3s pod/service CIDRs. The chart derives Collabora's WOPI allowlist from
  # podSubnet; the default (10.244.0.0/16) is wrong for k3s and breaks all
  # office-document opening with "Unauthorized WOPI host".
  networking:
    podSubnet:
      - "10.42.0.0/16"
    serviceSubnet:
      - "10.43.0.0/16"

# Per-app namespaces are REQUIRED: every app templates a Traefik Middleware
# named "hsts-header"; two apps in one namespace collide on Helm ownership.
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

# OIDC endpoints must be set explicitly — auto-derivation from the keycloak app
# does not propagate into sub-helmfiles (synapse renders authorization_endpoint: null
# and crashloops; Nextcloud gets a hostless discovery URI).
authentication:
  oidc:
    issuer: "https://id.DOMAIN/realms/mijnbureau"
    authorization_endpoint: "https://id.DOMAIN/realms/mijnbureau/protocol/openid-connect/auth"
    token_endpoint: "https://id.DOMAIN/realms/mijnbureau/protocol/openid-connect/token"
    introspection_endpoint: "https://id.DOMAIN/realms/mijnbureau/protocol/openid-connect/token/introspect"
    userinfo_endpoint: "https://id.DOMAIN/realms/mijnbureau/protocol/openid-connect/userinfo"
    end_session_endpoint: "https://id.DOMAIN/realms/mijnbureau/protocol/openid-connect/logout"
    jwks_uri: "https://id.DOMAIN/realms/mijnbureau/protocol/openid-connect/certs"

# OpenProject (Ruby 3.4) refuses world-writable tmp dirs, which is exactly what
# its mounted emptyDir volumes are. With a writable root filesystem it falls
# back to a usable tmp path. Without this the seeder job crashloops.
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

# The OpenProject chart needs TLS hosts spelled out or its ingress gets no
# tls: block and cert-manager never issues a certificate.
tls:
  openproject:
    - hosts:
        - openproject.DOMAIN
      secretName: openproject.DOMAIN-tls
```

## 4. Deploy

```bash
export MIJNBUREAU_MASTER_PASSWORD="change-me-please"   # pick something strong
export MIJNBUREAU_CREATE_NAMESPACES=true

yes | helmfile init        # interactive prompts; installs helm plugins
helmfile -e demo apply --skip-diff-on-install
```

This takes 10–20 minutes. If a re-run fails with "field is immutable" on a Job,
delete the named job (`kubectl delete job <name> -n <ns>`) and re-apply.

## 5. Single-node networking workarounds

Two unavoidable quirks of running everything on one box behind k3s Traefik:

**a) Hairpin: pods can't reach the cluster's own public IP.** Send `*.DOMAIN`
back to the in-cluster Traefik via CoreDNS (escape the dots in your domain):

```bash
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata: { name: coredns-custom, namespace: kube-system }
data:
  mb.override: |
    rewrite name regex (.*)\.DOMAIN_ESCAPED traefik.kube-system.svc.cluster.local answer auto
YAML
# DOMAIN_ESCAPED example: mb\.example\.com
kubectl -n kube-system rollout restart deploy/coredns
```

**b) k3s Traefik listens on 8443, not 443.** The bundled egress NetworkPolicies
allow 443 only, so apps can't call each other's public hostnames. Allow 8443 everywhere:

```bash
for ns in mb-keycloak mb-grist mb-element mb-collabora mb-nextcloud \
          mb-livekit mb-meet mb-docs mb-bureaublad mb-clamav mb-openproject; do
kubectl apply -f - <<YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: { name: allow-egress-traefik, namespace: $ns }
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
    - to: [{ podSelector: {} }]
    - to: [{ namespaceSelector: { matchLabels: { kubernetes.io/metadata.name: kube-system } } }]
      ports: [{ port: 8443, protocol: TCP }]
YAML
done
```

Wait for all certificates before continuing:

```bash
kubectl get certificate -A
# All must show READY=True
```

## 6. Post-deploy fixes

These are chart bugs with fixes pending upstream; apply by hand until merged.

### a) OpenProject: missing Traefik middleware

The chart references `hsts-header` but doesn't create it; Traefik silently drops
the entire route (plain 404s):

```bash
kubectl apply -f - <<'YAML'
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata: { name: hsts-header, namespace: mb-openproject }
spec:
  headers: { stsSeconds: 31536000, stsIncludeSubdomains: true, stsPreload: true }
YAML
```

### b) Docs: realtime collaboration 500s

The y-provider service sits on port 443 with a plain-HTTP backend, so Traefik
tries TLS against it:

```bash
kubectl patch svc docs-y-provider -n mb-docs --type=merge -p '{
  "spec": {"ports": [
    {"name": "http", "port": 80, "targetPort": 4444, "protocol": "TCP"},
    {"name": "internal-443", "port": 443, "targetPort": 4444, "protocol": "TCP"}
  ]}}'
```

### c) Docs: login 500s

Migrations run as `postgres` so the app role `docs` has no grants on the tables
it needs (docs runs on a CloudNativePG cluster; the superuser password lives in
the `docs-cluster-rw` secret):

```bash
PGPASS=$(kubectl get secret docs-cluster-rw -n mb-docs -o jsonpath='{.data.postgres-password}' | base64 -d)
kubectl exec -n mb-docs docs-cluster-rw-0 -- env PGPASSWORD="$PGPASS" psql -U postgres -h localhost -d docs -c "
  GRANT ALL ON ALL TABLES IN SCHEMA public TO docs;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO docs;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO docs;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO docs;"
```

### d) Nextcloud: can't open Office files

Its S3 client falls through the AWS credential chain to EC2 metadata (times out
on non-AWS hosts), and the SSRF guard blocks the CoreDNS-rewritten private IP:

```bash
MINIO_USER=$(kubectl get secret -n mb-nextcloud nextcloud-minio -o jsonpath='{.data.root-user}' | base64 -d)
MINIO_SECRET=$(kubectl get secret -n mb-nextcloud nextcloud-minio -o jsonpath='{.data.root-password}' | base64 -d)
kubectl set env deploy/nextcloud -n mb-nextcloud \
  AWS_ACCESS_KEY_ID="$MINIO_USER" AWS_SECRET_ACCESS_KEY="$MINIO_SECRET" AWS_EC2_METADATA_DISABLED=true
kubectl set env cronjob/nextcloud-cronjob -n mb-nextcloud \
  AWS_ACCESS_KEY_ID="$MINIO_USER" AWS_SECRET_ACCESS_KEY="$MINIO_SECRET" AWS_EC2_METADATA_DISABLED=true

kubectl exec -n mb-nextcloud deploy/nextcloud -- \
  php occ config:system:set allow_local_remote_servers --value=true --type=boolean

# Force a cron run with the fixed credentials — if a cron pod from before the
# env change already tried (and failed) to cache Collabora's capabilities,
# office files 500 on open until the next successful run:
kubectl create job --from=cronjob/nextcloud-cronjob cron-recache -n mb-nextcloud
```

### e) Collabora: rejects Nextcloud's WOPI requests

Nextcloud sends its host with an explicit `:443`; Collabora's configured alias has
none, so the anchored match fails ("Unauthorized WOPI host"). Make the alias
port-tolerant (replace `DOMAIN_ESCAPED` with dots escaped, e.g. `mb\.example\.com`):

```bash
kubectl set env deploy/collabora-online -n mb-collabora \
  'extra_params=--o:ssl.enable=false --o:ssl.termination=true \
  --o:storage.wopi.alias_groups.mode=groups \
  --o:storage.wopi.alias_groups.group[0].host=https://nextcloud\.DOMAIN_ESCAPED(:443)? \
  --o:storage.wopi.alias_groups.group[1].host=https://drive\.DOMAIN_ESCAPED(:443)?'
```

### f) Grist: file imports fail

Two replicas with no session affinity; the upload lands on one pod and the import
request hits the other:

```bash
kubectl patch hpa grist -n mb-grist -p '{"spec":{"minReplicas":1,"maxReplicas":1}}'
kubectl scale deploy grist -n mb-grist --replicas=1
```

### g) ClamAV: crashloops on startup

The bundled NetworkPolicy only allows DNS egress (port 53), so freshclam can
resolve the definitions server but never download from it:

```bash
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: { name: allow-clamav-freshclam, namespace: mb-clamav }
spec:
  podSelector:
    matchLabels: { app.kubernetes.io/name: clamav }
  policyTypes: [Egress]
  egress:
    - ports: [{ port: 443, protocol: TCP }]
YAML
kubectl delete pod -n mb-clamav -l app.kubernetes.io/name=clamav
```

### h) Restart OIDC apps

So they re-read discovery against the now-valid certificates:

```bash
for d in "deploy/grist -n mb-grist" "deploy/docs-backend -n mb-docs" \
         "deploy/nextcloud -n mb-nextcloud" "deploy/meet-backend -n mb-meet" \
         "deploy/synapse -n mb-element"; do
  kubectl rollout restart $d
done
```

## 7. (Optional) Saner session lifetimes

Out of the box Keycloak issues 5-minute tokens with a 30-minute idle timeout, so
you re-authenticate constantly across all apps. Stretch them:

```bash
KC_PASS=$(kubectl get secret keycloak-keycloak -n mb-keycloak -o jsonpath='{.data.admin-password}' | base64 -d)
TOKEN=$(curl -s "https://id.DOMAIN/realms/master/protocol/openid-connect/token" \
  -d grant_type=password -d client_id=admin-cli -d username=admin -d "password=$KC_PASS" | python3 -c 'import sys,json;print(json.load(sys.stdin)["access_token"])')
curl -s -X PUT "https://id.DOMAIN/admin/realms/mijnbureau" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"accessTokenLifespan":1800,"ssoSessionIdleTimeout":604800,"ssoSessionMaxLifespan":2592000,"rememberMe":true}'
```

## 8. Log in

| URL | What |
|---|---|
| `https://bureaublad.DOMAIN` | Dashboard (start here) |
| `https://nextcloud.DOMAIN` | Files + Office (Word/Excel-style editing) |
| `https://docs.DOMAIN` | Notion-style collaborative notes |
| `https://grist.DOMAIN` | Airtable-style data grids |
| `https://element.DOMAIN` | Chat (Matrix) |
| `https://meet.DOMAIN` | Video calls |
| `https://openproject.DOMAIN` | Project management |
| `https://id.DOMAIN` | Keycloak (SSO) |

Demo users (seeded automatically): `johndoe` / `janedoe`, password `myStrongPassword123`.

Keycloak admin console (`https://id.DOMAIN/admin`): username `admin`, password from:

```bash
kubectl get secret keycloak-keycloak -n mb-keycloak -o jsonpath='{.data.admin-password}' | base64 -d
```

## Known remaining issues

- Nextcloud Office "New file" / "Save As" from inside the editor crashes
  (richdocuments / Nextcloud version incompatibility — create files from the
  Files app ➕ instead).
- OpenProject is not integrated into the Bureaublad dashboard (upstream gap).
- The AI assistant (Conversations) and Drive are not exposed in this setup; Ollama is off.

## Teardown

```bash
/usr/local/bin/k3s-uninstall.sh   # removes k3s and ALL data
```
