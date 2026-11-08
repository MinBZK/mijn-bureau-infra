# Messages

MijnBureau supplies an installation of [Messages](https://github.com/suitenumerique/messages),
the collaborative inbox and email application from LaSuite. Users get a webmail interface,
shared inboxes, threading, search, attachments and message imports. Authentication uses the
same Keycloak realm as the other applications.

Messages is more than a web application: it also contains an inbound SMTP server (MTA), an
outbound delivery pipeline and search infrastructure. You need control over the DNS records
of every domain that receives mail.

## Configuration

To configure this solution, you can override the default settings for your environment. The
defaults are located in the folder `helmfile/environments/default`.

| Name                                   | Description                                                         |
| -------------------------------------- | ------------------------------------------------------------------- |
| `global.domain`                        | The domain name of your MijnBureau instance                         |
| `global.hostname.messages`             | The subdomain of the Messages web application                       |
| `global.hostname.messages-minio`       | Public object-storage endpoint used for resumable imports           |
| `application.messages.enabled`         | Enable Messages                                                     |
| `application.messages.namespace`       | The Kubernetes namespace name                                       |
| `application.messages.mailDomain`      | Optional mail domain created on install with `oidc_autojoin`        |
| `application.messages.technicalDomain` | Hostname used in MX/SPF records. Defaults to `mail.<global.domain>` |
| `application.messages.loadBalancerIP`  | Optional fixed public SMTP address                                  |
| `application.messages.relayHost`       | Optional outbound relay (`host:port`); empty means direct delivery  |
| `application.messages.relayUsername`   | Optional outbound relay username                                    |
| `application.messages.extraEnvVars`    | Extra environment variables for the backend and worker              |
| `authentication.client.messages.*`     | OIDC client credentials                                             |
| `database.messages.*`                  | PostgreSQL connection details                                       |
| `cache.messages.*`                     | Valkey connection details                                           |
| `objectstore.messages.*`               | MinIO/S3 endpoint, credentials and bucket names                     |
| `search.messages.*`                    | OpenSearch endpoint                                                 |
| `pvc.messages.*`                       | Storage for PostgreSQL, Valkey, MinIO and OpenSearch                |
| `resource.messages.*`                  | Explicit resources for each component                               |
| `autoscaling.horizontal.messages.*`    | Autoscaling for the backend, worker, frontend and MTA               |
| `container.messages_*`                 | Container image selection                                           |
| `container.opensearch`                 | OpenSearch image selection                                          |
| `secret.messages.adminUser`            | Django admin user                                                   |
| `secret.messages.adminPassword`        | Django admin password                                               |
| `secret.messages.mtaRelayPassword`     | SMTP relay password when `relayHost` is set                         |

## Components

| Component   | Description                                                                 |
| ----------- | --------------------------------------------------------------------------- |
| Backend     | Django REST API, OIDC login, mailbox logic and message delivery (gunicorn)  |
| Worker      | Celery worker for inbound/outbound mail, imports, search and periodic tasks |
| Frontend    | React single-page application and Caddy reverse proxy                       |
| Inbound MTA | Pure-Python SMTP server (`pymta`) that validates recipients via the API     |

The `pymta` server holds messages in memory while it validates them. The chart defaults
`PYMTA_MAX_CONCURRENT_DATA` to 20, which fits the default 512 MiB MTA preset for 10 MiB
messages. Raise it only together with the MTA memory limit; the upstream sizing rule is
roughly `concurrent messages × max message size × 2.2 + 64 MiB`.
| PostgreSQL | Mailboxes, messages, threads, permissions and DKIM keys (CloudNativePG) |
| Valkey | Cache, Celery broker and search coalescing buffers |
| OpenSearch | Full-text search index |
| MinIO / S3 | Message imports, blob offload and exports |
| Keycloak | OIDC identity provider |

The frontend also proxies `/api`, `/admin` and `/static` to the backend, so only one web
hostname is required. The inbound MTA is exposed separately because SMTP cannot go through
the HTTP gateway.

## First-time setup

1. **Deploy the application.** The demo environment deploys PostgreSQL, Valkey, MinIO and
   OpenSearch (unless `search.messages.url` is set). Production environments can use external
   services by setting
   `search.messages.url`, `database.messages.*`, `cache.messages.*` and
   `objectstore.messages.*`.
2. **Configure DNS.** Create the web record, the SMTP records and the MX records. See
   [DNS](../dns.md#email-messages) and the section below.
3. **Log in.** Open `https://messages.<domain>` and sign in through Keycloak. If
   `application.messages.mailDomain` is set, a mail domain with `oidc_autojoin` is created
   during installation. Otherwise create one in the Django admin at
   `https://messages.<domain>/admin/` and enable **OIDC autojoin**.
4. **Publish the DNS records shown by the application.** The mail domain detail page shows
   the expected MX, SPF, DMARC and DKIM records, including the generated DKIM public key.

## Mail domains and mailboxes

A mail domain controls how users get a mailbox:

| Mail domain setting | Who creates the mailbox                                    |
| ------------------- | ---------------------------------------------------------- |
| `oidc_autojoin`     | Messages creates a mailbox for every user that logs in     |
| `identity_sync`     | An administrator creates mailboxes and Messages syncs them |
| neither             | Shared mailboxes only; grant access to users manually      |

`identity_sync` requires the optional Keycloak service-account integration from the upstream
identity-provider guide and the `messages-keycloak` image, which is not part of the default
MijnBureau deployment. For most installations `oidc_autojoin` is enough.

## DNS and MX records

The default technical domain is `mail.<global.domain>`. The application expects these DNS
records for every mail domain (replace `example.com` with the mail domain and
`mail.example.com` with the technical domain):

```text
; Inbound SMTP hosts
mail.example.com.        A     <SMTP load balancer IPv4>
mail.example.com.        AAAA  <SMTP load balancer IPv6>
mx1.mail.example.com.    A     <SMTP load balancer IPv4>
mx1.mail.example.com.    AAAA  <SMTP load balancer IPv6>
mx2.mail.example.com.    A     <SMTP load balancer IPv4>
mx2.mail.example.com.    AAAA  <SMTP load balancer IPv6>

; SPF for the technical domain. Add all outbound IPs here, or use a relay.
_spf.mail.example.com.   TXT   "v=spf1 ip4:<outbound IPv4> -all"

; Records for the mail domain itself
example.com.             MX 10 mx1.mail.example.com.
example.com.             MX 20 mx2.mail.example.com.
example.com.             TXT   "v=spf1 include:_spf.mail.example.com -all"
_dmarc.example.com.      TXT   "v=DMARC1; p=reject; adkim=s; aspf=s;"

; DKIM, copied from the mail domain detail page in the admin
stmessages._domainkey.example.com. TXT "v=DKIM1; k=rsa; p=<public key>"
```

Get the SMTP load balancer address with:

```bash
kubectl get service messages-mta -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Notes:

- The MX record targets come from `MESSAGES_DNS_RECORDS`. The default template uses
  `mx1.<technicalDomain>` and `mx2.<technicalDomain>`. If you only have one SMTP address, you
  can point both names at the same IP, or override `application.messages.dnsRecords` to use a
  single MX target.
- The MTA `Service` is a `LoadBalancer` with `externalTrafficPolicy: Local`. Make sure your
  cloud or bare-metal load balancer preserves the client IP; SPF and spam checks need it.
- Open inbound TCP port 25 to the load balancer. Many cloud providers block outbound port 25;
  set `application.messages.relayHost` when direct delivery is not possible.
- Publish a matching PTR (reverse DNS) record for every outbound IP. It should resolve to the
  technical domain, for example `mail.example.com`.
- DKIM keys are generated automatically when a mail domain is created. The private key is
  encrypted with the installation's master password; keep `MIJNBUREAU_MASTER_PASSWORD` stable.

See [DNS](../dns.md#email-messages) for the general MijnBureau DNS setup.

## Outbound mail

By default Messages delivers mail directly to the recipient's MX on port 25. This requires:

- outbound port 25 from the Kubernetes cluster;
- a public egress IP with a matching PTR record;
- that IP (or its SPF include) authorized in the sending domain's SPF record;
- a good IP reputation.

If direct delivery is not possible, configure an SMTP relay:

```yaml
application:
  messages:
    relayHost: smtp.example.com:587
    relayUsername: messages@example.com
```

Relay mode uses mandatory TLS (`secure`). If your relay uses a self-signed certificate,
terminate TLS correctly or use direct delivery instead.

Set the relay password through the `MESSAGES_MTA_RELAY_PASSWORD` environment variable when
rendering Helmfile, or set `secret.messages.mtaRelayPassword` in your environment values.

## Object storage and imports

Messages uses four buckets:

| Bucket                      | Purpose                                  |
| --------------------------- | ---------------------------------------- |
| `st-messages-media-storage` | Media and uploaded images                |
| `msg-imports`               | Resumable EML/MBOX/PST/IMAP imports      |
| `msg-blobs`                 | Optional tiered storage for raw messages |
| `msg-exports`               | Offline exports such as the spam corpus  |

The demo environment creates them in MinIO. The public `messages-minio.<domain>` endpoint is
used to rewrite presigned upload URLs, so the browser can upload imports directly. Keep that
hostname reachable and keep the bucket CORS configuration in sync with the web hostname; the
install job runs `bucket_cors` for all four buckets. When using an external S3-compatible
store, set `objectstore.messages.publicUrl` to the browser-reachable endpoint. If you do not
expose a `messages-minio` hostname, remove it from `global.hostname` so the gateway does not
request a certificate for it.

## Search

OpenSearch indexes threads and messages. The demo environment deploys a single-node
OpenSearch instance with the security plugin disabled and a network policy that only allows
access from the same namespace. For production, point `search.messages.url` at an external
OpenSearch cluster and protect it with network policies or a service mesh.

The instance must allow `vm.max_map_count=262144` on its nodes. Check this before enabling
OpenSearch on a new cluster.

## Optional integrations

- **Drive:** set `application.drive.enabled` and Messages exposes a "save to Drive" action.
  Drive must also allow the Messages OIDC audience and SDK origin; see the Drive
  documentation.
- **AI:** summaries and auto-labelling are enabled automatically when `ai.llm` has both a
  model and an endpoint, or when Ollama is enabled as the fallback LLM.
- **Spam filtering:** Messages can call an rspamd `/checkv2` endpoint. Set
  `SPAM_CONFIG` through `application.messages.extraEnvVars` or a mail domain's custom
  settings.

## More information

- [Upstream repository](https://github.com/suitenumerique/messages)
- [Architecture documentation](https://github.com/suitenumerique/messages/blob/main/docs/architecture.md)
- [Self-hosting guide](https://github.com/suitenumerique/messages/blob/main/docs/self-hosting.md)
- [Environment variables](https://github.com/suitenumerique/messages/blob/main/docs/env.md)
