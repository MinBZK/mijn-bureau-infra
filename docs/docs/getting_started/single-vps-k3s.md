---
sidebar_position: 6
description: Deploy the full MijnBureau suite on a single Linux server using k3s
---

# Get started on a single VPS with K3s

This guide shows you how to get the full MijnBureau suite (Keycloak SSO, Nextcloud + Collabora office,
Grist, Docs, Element chat, Meet video, Bureaublad dashboard) running on a single Linux server using K3s

This aims to be the fastest and cheapest way to have a fully functional MijnBureau set up running fully within the EU.

You can use it to evaluate the functionality or it might even be enough to run as a production instance for a small company or department.

We tested it on an [AX41](https://www.hetzner.com/dedicated-rootserver/ax41/) from Hetzner, which costs €60/month and gives you 64GB of RAM and 512GB SSD RAID.

:::warning
Single node, no backups, no disaster recovery, all datastores in-cluster, secrets
derived from one master password. Don't put real data on it without adding backups
(Velero or similar) and rotating every secret. Antivirus (ClamAV) and project
management (OpenProject) are disabled in this setup to keep it lean.
:::

## Prerequisites

- A server with **≥12 vCPU and ≥48 GiB RAM**, Ubuntu 24.04, root access.
- A **wildcard DNS record**: `*.DOMAIN` pointing to your server's IPv4 address. A subdomain is fine, e.g. `*.mb.example.com`, means you will access individual services on sub domains of that like `docs.mb.example.com`

Throughout, replace `DOMAIN` with your domain (e.g. `mb.example.com`) and pick a
strong master password as every app secret is derived from that.

There are two ways to do this:

- **[Part 1 — Quick start](#part-1-quick-start)** runs one script that does
  everything. Best if you just want a working instance.
- **[Part 2 — Step by step](#part-2--step-by-step)** runs the same work as a
  series of small scripts, showing what each one does and why. Best if you want to
  understand the setup or adapt it.

## Part 1: Quick start

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

| App            | URL                         | What to check                           |
| -------------- | --------------------------- | --------------------------------------- |
| Dashboard      | `https://bureaublad.DOMAIN` | Loads and shows the app tiles           |
| Files + Office | `https://nextcloud.DOMAIN`  | Log in and upload an `.xlsx` file       |
| Docs           | `https://docs.DOMAIN`       | Log in, create a document, type into it |
| Grist          | `https://grist.DOMAIN`      | Create a table, import a CSV            |
| Chat           | `https://element.DOMAIN`    | Loads and you can send a message        |
| Video          | `https://meet.DOMAIN`       | Start a meeting, camera/mic work        |
| SSO            | `https://id.DOMAIN`         | Keycloak login works                    |

If everything above checks out, you're done. The rest of this page explains how it
works.

---

## Part 2 — Step by step

This does exactly what Part 1 does, but as separate scripts you run one at a time,
so you can see each fix and understand why it's needed.

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

What this does:

- Installs k3s, Helm and Helmfile, plus cert-manager and a Let's Encrypt issuer for TLS.
- Writes the demo config: drops resource requests so the suite fits one box, sets the k3s pod/service CIDRs, pins the OIDC endpoints explicitly, and disables ClamAV, OpenProject and Ollama.
- Runs `helmfile -e demo apply` to deploy everything.
- Saves your domain to `/etc/mijnbureau/domain` so the later scripts reuse it.

View the script [here](https://github.com/MinBZK/mijn-bureau-infra/blob/main/scripts/single-vps-deploy/01-deploy.sh).

### 2. Single-node networking — `02-networking.sh`

```bash
curl -fsSL $BASE/02-networking.sh | bash
```

What this does (the default setup assumes a load balancer for ingress; on one box we adjust):

- Rewrites `*.DOMAIN` in CoreDNS to the in-cluster Traefik service, so a pod can reach the cluster's own public hostnames (the single-node hairpin problem).
- Adds egress NetworkPolicies allowing traffic to Traefik on port 8443 (k3s Traefik listens there, not 443), so the apps can call each other.

View the script [here](https://github.com/MinBZK/mijn-bureau-infra/blob/main/scripts/single-vps-deploy/02-networking.sh).

### 3. Wait for certificates

The OIDC apps need valid certs to read Keycloak's discovery document, so wait
until every certificate is issued before continuing:

```bash
kubectl get certificate -A
# Wait until every row shows READY=True (a few minutes).
```

(The `install.sh` parent does this wait automatically.)

### 4. Nextcloud networking + restart OIDC apps — `03-restart-oidc-apps.sh`

```bash
curl -fsSL $BASE/03-restart-oidc-apps.sh | bash
```

What this does:

- Lets Nextcloud make server-side calls to the now-internal `id.DOMAIN` (its SSRF guard blocks private IPs by default), so OIDC login works.
- Adds the Traefik pod subnet to Nextcloud's trusted proxies, so it sees real client IPs instead of throttling every user as one ("Too many requests").
- Restarts the OIDC apps so they re-read Keycloak discovery now that the path and certs are ready.

View the script [here](https://github.com/MinBZK/mijn-bureau-infra/blob/main/scripts/single-vps-deploy/03-restart-oidc-apps.sh).

### 5. Nextcloud Office — `04-nextcloud-office.sh`

```bash
curl -fsSL $BASE/04-nextcloud-office.sh | bash
```

What this does:

- Waits for Nextcloud to be ready.
- Refreshes the Collabora capabilities cache. The first fetch happened before the networking was up and cached a failure, which makes every Office file 500 on open until it's refreshed.

View the script [here](https://github.com/MinBZK/mijn-bureau-infra/blob/main/scripts/single-vps-deploy/04-nextcloud-office.sh).

### 6. Docs — `05-docs.sh`

```bash
curl -fsSL $BASE/05-docs.sh | bash
```

What this does:

- Re-maps the docs y-provider service ports so realtime collaboration works (it was serving plain HTTP on port 443, which Traefik tries to speak TLS to).
- Grants the `docs` database role access to its tables (migrations created them as the superuser), fixing login 500s.

View the script [here](https://github.com/MinBZK/mijn-bureau-infra/blob/main/scripts/single-vps-deploy/05-docs.sh).

### 7. Grist — `06-grist.sh`

```bash
curl -fsSL $BASE/06-grist.sh | bash
```

What this does:

- Pins Grist to a single replica, so a file upload and its follow-up import request hit the same pod (otherwise you get "Unknown upload").

View the script [here](https://github.com/MinBZK/mijn-bureau-infra/blob/main/scripts/single-vps-deploy/06-grist.sh).

### 8. Session lifetimes (optional) — `07-session-lifetimes.sh`

```bash
curl -fsSL $BASE/07-session-lifetimes.sh | bash
```

What this does:

- Widens Keycloak's short default token/session lifetimes on the `mijnbureau` realm (30-minute access token, 7-day idle timeout, 30-day max session) and enables "remember me", so you aren't constantly re-logging in.

View the script [here](https://github.com/MinBZK/mijn-bureau-infra/blob/main/scripts/single-vps-deploy/07-session-lifetimes.sh).

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
