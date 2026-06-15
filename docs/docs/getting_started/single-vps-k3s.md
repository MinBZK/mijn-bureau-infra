---
sidebar_position: 6
description: Deploy the full MijnBureau suite on a single Linux server using k3s and Helmfile, with real TLS certificates and working SSO, in roughly 30–45 minutes.
---

# Get started on a single VPS with K3s

This gets the full MijnBureau suite (Keycloak SSO, Nextcloud + Collabora office,
Grist, Docs, Element chat, Meet video, Bureaublad dashboard) running on **one
Linux server** with real TLS certificates and working single sign-on, in roughly
30–45 minutes.

:::warning Demo/evaluation only
Single node, no backups, no disaster recovery, all datastores in-cluster, secrets
derived from one master password. Don't put real data on it without adding backups
(Velero or similar) and rotating every secret. Antivirus (ClamAV) and project
management (OpenProject) are disabled in this setup to keep it lean.
:::

## Prerequisites

- A server with **≥12 vCPU and ≥48 GiB RAM**, Ubuntu 24.04, root access.
  (Less RAM may work since resource requests are disabled, but Nextcloud + Synapse
  together are hungry.)
- A **wildcard DNS record**: `*.DOMAIN` → your server's IPv4. (~16 hostnames are
  needed; the wildcard covers all of them. Remove any AAAA record unless your box
  serves IPv6.)
- Nothing else listening on ports 80/443.

Throughout, replace `DOMAIN` with your domain (e.g. `mb.example.com`) and pick a
strong master password — every app secret is derived from it.

There are two ways to do this:

- **[Part 1 — Quick start](#part-1--quick-start)** runs one script that does
  everything. Best if you just want a working instance.
- **[Part 2 — Step by step](#part-2--step-by-step)** runs the same work as a
  series of small scripts, showing what each one does and why. Best if you want to
  understand the setup or adapt it.

---

## Part 1 — Quick start

Run this on a fresh Ubuntu 24.04 box as root, substituting your domain, an email
(for Let's Encrypt expiry notices), and a master password:

```bash
curl -fsSL https://raw.githubusercontent.com/MinBZK/mijn-bureau-infra/main/scripts/single-vps-deploy/install.sh \
  | bash -s -- DOMAIN you@example.com 'YOUR_MASTER_PASSWORD'
```

It installs k3s, deploys the suite, waits for TLS certificates to be issued, then
applies the post-deploy fixes. Allow 30–45 minutes. When it finishes, log in at
`https://bureaublad.DOMAIN`.

### Log in

Demo users (seeded automatically): `johndoe` / `janedoe`, password
`myStrongPassword123`.

Keycloak admin console (`https://id.DOMAIN/admin`), username `admin`, password from:

```bash
kubectl get secret keycloak-keycloak -n mb-keycloak \
  -o jsonpath='{.data.admin-password}' | base64 -d
```

### Verify each app

| App | URL | What to check |
|---|---|---|
| Dashboard | `https://bureaublad.DOMAIN` | Loads and shows the app tiles |
| Files + Office | `https://nextcloud.DOMAIN` | Log in, open or create an `.xlsx` — it opens in Collabora |
| Docs | `https://docs.DOMAIN` | Log in, create a document, type into it — no 500 |
| Grist | `https://grist.DOMAIN` | Create a table, import a CSV — no "Unknown upload" error |
| Chat | `https://element.DOMAIN` | Loads and you can send a message |
| Video | `https://meet.DOMAIN` | Start a meeting, camera/mic work |
| SSO | `https://id.DOMAIN` | Keycloak login works |

If everything above checks out, you're done. The rest of this page explains how it
works.

---

## Part 2 — Step by step

This does exactly what Part 1 does, but as separate scripts you run one at a time,
so you can see each fix and understand why it's needed. Every script is
idempotent — re-running it is safe.

All scripts live in
[`scripts/single-vps-deploy/`](https://github.com/MinBZK/mijn-bureau-infra/tree/main/scripts/single-vps-deploy)
and are fetched the same way:

```bash
BASE=https://raw.githubusercontent.com/MinBZK/mijn-bureau-infra/main/scripts/single-vps-deploy
```

### 1. Deploy — `01-deploy.sh`

```bash
curl -fsSL $BASE/01-deploy.sh | bash -s -- DOMAIN you@example.com 'YOUR_MASTER_PASSWORD'
```

This installs k3s, Helm and Helmfile; installs cert-manager and a Let's Encrypt
`ClusterIssuer`; clones the repo; writes the demo environment config; and runs
`helmfile -e demo apply`. It also saves your domain to `/etc/mijnbureau/domain` so
the later scripts pick it up automatically.

The config it writes makes a few non-obvious but essential choices:

```yaml
global:
  domain: "DOMAIN"
  # The demo "small" preset *requests* ~22 CPU cores and will never schedule on
  # one box. "none" drops requests/limits so apps share whatever exists.
  resourcesPreset: "none"
  resourcesPresetPerApp: { ... all apps: "none" ... }
  tls:
    enabled: true
    selfSigned: false        # real certs via cert-manager; self-signed breaks SSO

cluster:
  routingMode: ingress
  ingress:
    type: traefik
    annotations: { cert-manager.io/cluster-issuer: letsencrypt-prod }
  # The chart derives Collabora's WOPI allowlist from podSubnet; the default
  # (10.244.0.0/16) is wrong for k3s and breaks office-document opening.
  networking:
    podSubnet: ["10.42.0.0/16"]
    serviceSubnet: ["10.43.0.0/16"]

application:
  ollama:      { enabled: false }   # local LLM: heavy, off
  clamav:      { enabled: false }   # antivirus: off for this setup
  openproject: { enabled: false }   # project management: off for this setup
  # Per-app namespaces are REQUIRED: every app templates a Traefik Middleware
  # named "hsts-header"; two apps in one namespace collide on Helm ownership.
  keycloak: { namespace: mb-keycloak }
  # ... grist, element, collabora, nextcloud, livekit, meet, docs, bureaublad ...

# OIDC endpoints must be set explicitly — auto-derivation from the keycloak app
# does not propagate into the sub-helmfiles (synapse renders a null
# authorization_endpoint and crashloops; Nextcloud gets a hostless discovery URI).
authentication:
  oidc:
    issuer: "https://id.DOMAIN/realms/mijnbureau"
    # ... all 7 endpoints spelled out ...
```

**Why real certificates are required, not optional:** with self-signed certs the
server-side OIDC calls between apps fail TLS verification and SSO breaks.

### 2. Single-node networking — `02-networking.sh`

```bash
curl -fsSL $BASE/02-networking.sh | bash
```

Two unavoidable quirks of running everything on one box behind k3s Traefik:

```bash
# a) Hairpin: a pod can't reach its own node's public IP. Rewrite *.DOMAIN via
#    CoreDNS to the in-cluster Traefik service so traffic stays internal.
kubectl apply -f - <<YAML
apiVersion: v1
kind: ConfigMap
metadata: { name: coredns-custom, namespace: kube-system }
data:
  mb.override: |
    rewrite name regex (.*)\.DOMAIN_ESCAPED traefik.kube-system.svc.cluster.local answer auto
YAML
kubectl -n kube-system rollout restart deploy/coredns

# b) k3s Traefik listens on 8443, not 443; the bundled egress NetworkPolicies only
#    allow 443, so apps can't call each other's public hostnames. Allow 8443.
for ns in mb-keycloak mb-grist mb-element mb-collabora mb-nextcloud \
          mb-livekit mb-meet mb-docs mb-bureaublad; do
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

This is a single-node issue specifically: on a multi-node cluster behind a real
external load balancer, a pod reaching the public IP lands on a different node and
comes back normally, so the hairpin never happens.

### 3. Wait for certificates

Before continuing, every certificate must be issued — the OIDC apps need valid
certs to read Keycloak's discovery document:

```bash
kubectl get certificate -A
# Wait until every row shows READY=True (a few minutes).
```

(The `install.sh` parent does this wait automatically.)

### 4. Nextcloud networking + restart OIDC apps — `03-restart-oidc-apps.sh`

```bash
curl -fsSL $BASE/03-restart-oidc-apps.sh | bash
```

```bash
# Step 2a's CoreDNS rewrite resolves id.DOMAIN to a private IP. Nextcloud's SSRF
# guard refuses server-side requests to private IPs unless this is enabled, so
# OIDC discovery fails ("Could not reach the provider") and login 404s.
kubectl exec -n mb-nextcloud deploy/nextcloud -- \
  php occ config:system:set allow_local_remote_servers --value=true --type=boolean

# Traefik runs in the pod subnet (10.42.0.0/16) but Nextcloud's trusted_proxies
# only lists the service subnet (10.43.0.0/16), so Nextcloud sees every request
# as one internal IP — all users share one rate-limit bucket ("Too many requests")
# and client IPs are logged wrong. Add the pod subnet.
kubectl exec -n mb-nextcloud deploy/nextcloud -- \
  php occ config:system:set trusted_proxies 1 --value=10.42.0.0/16

# Each app fetched Keycloak's discovery at startup, before the network path and
# certs were ready; that failure is sticky until the pod restarts.
kubectl rollout restart deploy/grist -n mb-grist
kubectl rollout restart deploy/docs-backend -n mb-docs
kubectl rollout restart deploy/nextcloud -n mb-nextcloud
kubectl rollout restart deploy/meet-backend -n mb-meet
kubectl rollout restart deploy/synapse -n mb-element
```

### 5. Nextcloud Office — `04-nextcloud-office.sh`

```bash
curl -fsSL $BASE/04-nextcloud-office.sh | bash
```

```bash
kubectl rollout status deploy/nextcloud -n mb-nextcloud --timeout=300s
# richdocuments caches the capabilities doc it fetches from Collabora. On first
# deploy that fetch happened before the networking existed, so an empty/failed
# response got cached and every file-open 500s (xpath() on false). Re-fetch it now
# that the path works.
kubectl exec -n mb-nextcloud deploy/nextcloud -- php occ richdocuments:activate-config
```

This is a first-deploy ordering artifact, not a recurring problem — once the cache
holds a valid response it stays good.

### 6. Docs — `05-docs.sh`

```bash
curl -fsSL $BASE/05-docs.sh | bash
```

```bash
# b) The y-provider service sits on port 443 with a plain-HTTP backend, so Traefik
#    tries TLS against it and realtime collaboration 500s. Re-map the ports.
kubectl patch svc docs-y-provider -n mb-docs --type=merge -p '{
  "spec": {"ports": [
    {"name": "http", "port": 80, "targetPort": 4444, "protocol": "TCP"},
    {"name": "internal-443", "port": 443, "targetPort": 4444, "protocol": "TCP"}
  ]}}'

# c) Migrations run as the postgres superuser, so the app role `docs` has no grants
#    on its tables and login 500s. Grant them (CloudNativePG; superuser password in
#    the docs-cluster-rw secret).
PGPASS=$(kubectl get secret docs-cluster-rw -n mb-docs -o jsonpath='{.data.postgres-password}' | base64 -d)
kubectl exec -n mb-docs docs-cluster-rw-0 -- env PGPASSWORD="$PGPASS" psql -U postgres -h localhost -d docs -c "
  GRANT ALL ON ALL TABLES IN SCHEMA public TO docs;
  GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO docs;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO docs;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO docs;"
```

### 7. Grist — `06-grist.sh`

```bash
curl -fsSL $BASE/06-grist.sh | bash
```

```bash
# Grist runs two replicas with no session affinity, so a file upload lands on one
# pod and the import request hits the other ("Unknown upload"). Pin to one replica.
kubectl patch hpa grist -n mb-grist -p '{"spec":{"minReplicas":1,"maxReplicas":1}}'
kubectl scale deploy grist -n mb-grist --replicas=1
```

### 8. Session lifetimes (optional) — `07-session-lifetimes.sh`

```bash
curl -fsSL $BASE/07-session-lifetimes.sh | bash
```

Out of the box Keycloak issues 5-minute tokens with a 30-minute idle timeout, so
you re-authenticate constantly. This widens them to a 30-minute access token, a
7-day idle timeout, a 30-day max session, and enables "remember me" on the
`mijnbureau` realm.

---

## Known limitations

- Nextcloud Office "New file" / "Save As" from inside the editor can crash on some
  versions — create files from the Files app's ➕ instead.
- ClamAV (antivirus) and OpenProject are disabled here. To re-enable, set
  `enabled: true` for them in the config in `01-deploy.sh`; OpenProject also needs
  the `security.openproject` and `tls.openproject` blocks (and a `hsts-header`
  Middleware created in its namespace).
- The AI assistant (Conversations) and Drive are not exposed in this setup.

## Teardown

```bash
/usr/local/bin/k3s-uninstall.sh   # removes k3s and ALL data
```
