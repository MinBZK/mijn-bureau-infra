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
    collabora: "collabora"
    nextcloud: "nextcloud"
    livekit: "livekit"
    meet: "meet"
    conversations: "conversations"
    docs: "docs"
    bureaublad: "bureaublad"
    drive: "drive"
    projects: "projects"
    projects-minio: "projects-minio"
    dictaphone: "dictaphone"
    dictaphone-minio: "dictaphone-minio"
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
- `collabora.kubernetes.local`
- `nextcloud.kubernetes.local`
- `livekit.kubernetes.local`
- `meet.kubernetes.local`
- `conversations.kubernetes.local`
- `docs.kubernetes.local`
- `bureaublad.kubernetes.local`
- `drive.kubernetes.local`
- `projects.kubernetes.local`
- `projects-minio.kubernetes.local`
- `dictaphone.kubernetes.local`
- `dictaphone-minio.kubernetes.local`
- `static-conversations.kubernetes.local`
- `static-drive.kubernetes.local`
- `static-meet.kubernetes.local`
- `static-docs.kubernetes.local`
- `drive-minio.kubernetes.local`

## Cluster DNS network policies

DNS egress defaults to external port 53 without restricting the destination. To
configure separate external and internal DNS ports, override the following
settings from `helmfile/environments/default/cluster.yaml.gotmpl`:

```yaml
cluster:
  networking:
    dns:
      external:
        port: 1053
      internal:
        port: 5353
        namespace: kube-system
```

The external port is allowed to any destination and defaults to 53. An internal
DNS rule is added when its port or namespace is set; its port defaults to 53, and
an unset namespace allows that port to any destination. A namespace matches pods
in that namespace. Network policies are additive: if the external and internal
ports match, the external rule also allows that port outside the internal namespace.

These settings only change network policies, not the DNS resolver or its listening
port. Leave the internal namespace unset if DNS uses node-local or host-network
endpoints that cannot be matched by a namespace selector. The port seen by network
policies can also depend on your CNI and service port translation.
