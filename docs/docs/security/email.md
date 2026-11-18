---
sidebar_position: 8
---

# Secure email setup

This page is the end-to-end checklist for running Messages (E-mail) with working
authentication, TLS and a deliverability reputation. The record examples also appear in
[DNS](../dns.md#email-messages) and [Messages](../components/messages.md#dns-and-mx-records);
this page explains why each record exists and how to roll it out safely.

## What MijnBureau provides

| Capability                                     | Provided by                       | Notes                                                                                |
| ---------------------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------ |
| DKIM signing (outbound)                        | Messages backend                  | One RSA key per mail domain, selector `stmessages`, private key stored in PostgreSQL |
| DKIM/DMARC verification (inbound)              | rspamd                            | Adds authentication results and the forged/unverified sender banner                  |
| SPF, DMARC, MX record template                 | `application.messages.dnsRecords` | Rendered per mail domain and shown in the admin                                      |
| Public DKIM key                                | Messages admin                    | Shown on the mail domain detail page                                                 |
| Direct or relayed outbound SMTP                | `application.messages.relayHost`  | Relay mode also requires TLS to the relay                                            |
| MTA-STS, TLS-RPT, DANE, DMARC report ingestion | **Not provided**                  | Operator or relay responsibility                                                     |

Messages generates DKIM keys when a mail domain is created. The adminpanel shows the exact
records to publish, including the DKIM public key, so the adminpanel is the source of truth
rather than the examples below.

Outbound signing is always on, but two optional checks are off by default. Enable them
under `application.messages.extraEnvVars` once DNS is correct:

```yaml
application:
  messages:
    extraEnvVars:
      - name: MESSAGES_DKIM_VERIFY_OUTGOING
        value: "true" # verify your own signature before sending
      - name: MESSAGES_SPF_CHECK_OUTGOING
        value: "true" # refuse to send when the domain's SPF is misconfigured
```

## Checklist

1. **Web record** — `messages.<global.domain>` points at the ingress/Gateway address.
2. **Technical domain** — `application.messages.technicalDomain` defaults to
   `mail.<global.domain>`. MX, SPF include and PTR all refer to it.
3. **MX records** — two MX targets by default (`mx1`/`mx2` on the technical domain). Set
   `application.messages.dnsRecords` if you use a single target or a relay.
4. **SPF** — the template publishes `v=spf1 include:_spf.<technical-domain> -all`. Add
   every outbound IP or relay to that include; do not exceed the 10-DNS-lookup limit.
5. **DKIM** — publish the key from the admin:
   `stmessages._domainkey.<mail-domain> TXT "v=DKIM1; k=rsa; p=<key>"`.
6. **DMARC** — start with `p=none` and a reporting address, then move to `quarantine`
   and `reject` once reports are clean. The generated template uses
   `v=DMARC1; p=reject; adkim=s; aspf=s;`, which is strict: it assumes every sender is
   aligned and does not survive naive forwarding.
7. **PTR / reverse DNS** — every outbound IP needs a PTR that resolves to the technical
   domain, and the SMTP banner must use the same name.
8. **TLS** — inbound and outbound SMTP use TLS. With a relay configured, MijnBureau sets
   the outbound TLS security level to `secure`; without relay it is opportunistic (`may`).

## DKIM keys

- Selector: `stmessages` (set by the Messages chart, not by the environment values).
- Keys are per mail domain and generated on creation; there is no scheduled rotation.
- To rotate, create a new key/selector in the admin, publish the new TXT record, wait for
  DNS propagation, and only then remove the old record. Rotating by deleting the old key
  first causes failures for mail still signed with it.
- If a domain is served through a relay that signs its own mail, keep your DKIM record and
  let the relay add a second signature; do not remove yours.

## DMARC rollout

1. Publish `p=none` with `rua=mailto:dmarc@example.com` and send test mail to a
   check-auth service.
2. Watch reports for legitimate sources you missed (scanners, forms, the relay) and add
   them to SPF or DKIM.
3. Move to `p=quarantine` with a low percentage (`pct=25`), then to `p=reject`.
4. Keep `adkim`/`aspf` relaxed (`r`) while you forward mail; strict alignment breaks
   forwarding unless the forwarder rewrites the envelope.

MijnBureau does not parse DMARC reports. Use a reporting service or mailbox of your
choice.

## Forwarding and deliverability

Forwarding breaks SPF by design: the forwarder sends from its own IP but keeps your
domain in the envelope. Fixes are SRS (rewrite the envelope sender) and ARC (preserve the
authentication chain), plus a reputation service that keeps the sending IPs trusted.

**Soverin** is a Dutch (Amsterdam) email provider that offers exactly those pieces:

- forwarding with **SRS and ARC**, so forwarded mail keeps passing SPF/DKIM/DMARC;
- **SoSmart**, a reputation/deliverability service for independent mail servers;
- DKIM, SPF and DMARC for hosted domains, DANE/TLSA and encrypted transport, hosted in
  Dutch data centres.

You can use Soverin as the outbound relay for Messages by setting
`application.messages.relayHost` and `secret.messages.mtaRelayPassword`, or as the
forwarding/reputation layer in front of Messages. MijnBureau does not bundle or resell
Soverin; it is an independent commercial option, and the same role can be filled by
another provider that supports SRS/ARC and reputation monitoring.

## Verifying

```bash
dig +short MX example.com
dig +short TXT example.com
dig +short TXT _dmarc.example.com
dig +short TXT stmessages._domainkey.example.com
dig +short -x <outbound-ip>
```

Send a test message to a check-auth service and confirm `spf=pass`, `dkim=pass` and
`dmarc=pass`. Inbound authentication results are added by rspamd and visible in the
message headers.

## Related

- [Messages component](../components/messages.md)
- [DNS and MX records](../dns.md#email-messages)
- [Email feature](./email.md)
