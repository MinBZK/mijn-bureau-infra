---
sidebar_position: 10
---

# DNS

## Custom Domain Setup

To access MijnBureau from the internet, you need a domain name (like `mijnbureau.mycompany.com`) and configure it in your DNS system.

DNS is a service that translates domain names into IP addresses. When someone visits your domain, the DNS system directs them to the IP address of your server. You'll need to point your domain to the IP address of your Kubernetes cluster's ingress controller.

**What you need to do:**

1. Register a domain name with a domain registrar
2. Access your domain's DNS settings
3. Create DNS records that point your domain to your server's IP address
4. Update the `domain` setting in your configuration (shown below) to match your domain name

---

## Configuration

Below is the default configuration file for MijnBureau stored in `global.yaml.gotmpl`. Update the `global.domain` option to match your domain name. The `global.hostname` values can remain unchanged unless you want to rename specific urls for the applications.

```yaml
global:
  domain: "kubernetes.local"
  hostname:
    keycloak: "id"
    element: "element"
    synapse: "matrix"
    grist: "grist"
    collabora: "collabora"
    nextcloud: "nextcloud"
    openproject: "openproject"
    livekit: "livekit"
    meet: "meet"
    conversations: "conversations"
    docs: "docs"
    bureaublad: "bureaublad"
    drive: "drive"
    conversations-static: "static-conversations"
    drive-static: "static-drive"
    meet-static: "static-meet"
    docs-static: "static-docs"
    drive-minio: "drive-minio"
```

With this configuration, you need to create A and AAAA DNS records. A records map domain names to IPv4 addresses, while AAAA records map them to IPv6 addresses. IPv6 support is recommended and required for Dutch governmental organizations.

Create the following DNS records (replace `kubernetes.local` with your configured domain):

- `id.kubernetes.local`
- `id-admin.kubernetes.local`
- `element.kubernetes.local`
- `matrix.kubernetes.local`
- `grist.kubernetes.local`
- `collabora.kubernetes.local`
- `nextcloud.kubernetes.local`
- `livekit.kubernetes.local`
- `meet.kubernetes.local`
- `conversations.kubernetes.local`
- `docs.kubernetes.local`
- `bureaublad.kubernetes.local`
- `drive.kubernetes.local`
- `static-conversations.kubernetes.local`
- `static-drive.kubernetes.local`
- `static-meet.kubernetes.local`
- `static-docs.kubernetes.local`
- `drive-minio.kubernetes.local`
