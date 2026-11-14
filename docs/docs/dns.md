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
    mas: "mas"
    collabora: "collabora"
    nextcloud: "nextcloud"
    livekit: "livekit"
    meet: "meet"
    meet-minio: "meet-minio"
    conversations: "conversations"
    docs: "docs"
    bureaublad: "bureaublad"
    drive: "drive"
    projects: "projects"
    calendars: "calendars"
    projects-minio: "projects-minio"
    dictaphone: "dictaphone"
    dictaphone-minio: "dictaphone-minio"
    messages: "messages"
    messages-minio: "messages-minio"
    conversations-static: "static-conversations"
    drive-static: "static-drive"
    meet-static: "static-meet"
    docs-static: "static-docs"
    drive-minio: "drive-minio"
```

With this configuration, you need to create A and AAAA DNS records. A records map domain names to IPv4 addresses, while AAAA records map them to IPv6 addresses. IPv6 support is recommended and required for Dutch governmental organizations.

Create the following DNS records (replace `kubernetes.local` with your configured domain):

- `id.kubernetes.local`
- `element.kubernetes.local`
- `matrix.kubernetes.local`
- `mas.kubernetes.local` (Matrix Authentication Service, enabled by default with Element)
- `collabora.kubernetes.local`
- `nextcloud.kubernetes.local`
- `livekit.kubernetes.local`
- `meet.kubernetes.local`
- `meet-minio.kubernetes.local` (public endpoint for Meet recording downloads)
- `conversations.kubernetes.local`
- `docs.kubernetes.local`
- `bureaublad.kubernetes.local`
- `drive.kubernetes.local`
- `projects.kubernetes.local`
- `calendars.kubernetes.local`
- `projects-minio.kubernetes.local`
- `dictaphone.kubernetes.local`
- `dictaphone-minio.kubernetes.local`
- `messages.kubernetes.local`
- `messages-minio.kubernetes.local`
- `static-conversations.kubernetes.local`
- `static-drive.kubernetes.local`
- `static-meet.kubernetes.local`
- `static-docs.kubernetes.local`
- `drive-minio.kubernetes.local`

## Email (Messages)

The Messages application needs more than HTTP records: inbound mail is delivered by a
separate SMTP load balancer, and every mail domain needs MX, SPF, DKIM and DMARC records.
The default technical domain is `mail.<global.domain>`. Override
`application.messages.technicalDomain` if you use a different name.

Find the SMTP load balancer address:

```bash
kubectl get service messages-mta -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Create the following records. Replace `example.com` with the domain that receives mail and
`mail.example.com` with the configured technical domain.

```text
; Inbound SMTP hosts. All names may point at the same load balancer.
mail.example.com.       A     <SMTP load balancer IPv4>
mail.example.com.       AAAA  <SMTP load balancer IPv6>
mx1.mail.example.com.   A     <SMTP load balancer IPv4>
mx1.mail.example.com.   AAAA  <SMTP load balancer IPv6>
mx2.mail.example.com.   A     <SMTP load balancer IPv4>
mx2.mail.example.com.   AAAA  <SMTP load balancer IPv6>

; SPF for the technical domain. Include every outbound IP, or the relay IP.
_spf.mail.example.com.  TXT   "v=spf1 ip4:<outbound IPv4> -all"

; Records for each mail domain.
example.com.            MX 10 mx1.mail.example.com.
example.com.            MX 20 mx2.mail.example.com.
example.com.            TXT   "v=spf1 include:_spf.mail.example.com -all"
_dmarc.example.com.     TXT   "v=DMARC1; p=reject; adkim=s; aspf=s;"

; DKIM. Copy the value from the mail domain detail page in the Messages admin.
stmessages._domainkey.example.com. TXT "v=DKIM1; k=rsa; p=<public key>"
```

Additional requirements:

- Open inbound TCP port 25 to the SMTP load balancer.
- Make sure outbound TCP port 25 is allowed, or configure an SMTP relay with
  `application.messages.relayHost`.
- Publish a PTR record for every outbound IP. It should resolve to the technical domain.
- The default `MESSAGES_DNS_RECORDS` template expects two MX names (`mx1` and `mx2`). If you
  only have one address, point both names at the same IP or override
  `application.messages.dnsRecords` with a single MX record.
- If `application.messages.mailDomain` is set, the mail domain and its DKIM key are created
  during installation. Otherwise create the domain in the Django admin and enable
  **OIDC autojoin**.

See [Messages](components/messages.md) for the application configuration and outbound mail
setup.

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
