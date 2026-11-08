# Email

MijnBureau includes **Messages**, the collaborative inbox from LaSuite. It provides a
webmail interface, shared and personal mailboxes, threading, full-text search, attachments,
message imports and outbound delivery.

- [Messages component documentation](../components/messages.md)
- [DNS and MX records](../dns.md#email-messages)

## What you need

Messages is not only a web application. It also runs an inbound SMTP server and an outbound
delivery worker, so you need:

- control over the MX, SPF, DKIM and DMARC records of every mail domain;
- an SMTP load balancer address with inbound TCP port 25;
- outbound TCP port 25, or an SMTP relay;
- a public PTR record for the outbound address.

The default demo environment includes PostgreSQL, Valkey, OpenSearch, MinIO and the inbound
MTA. Production deployments can use external services.

## Mailboxes

Log in through Keycloak at `https://messages.<domain>`. A mail domain with **OIDC autojoin**
creates a mailbox for each user on first login. Administrators can also create shared
mailboxes and grant access to individual users.

## Opening the web app

![Messages](/img/features/email2.png)
