---
sidebar_position: 6
---

# Multi-tenancy

MijnBureau can serve multiple organisations from a single deployment. Tenancy is
expressed with [Keycloak organizations](https://www.keycloak.org/docs/latest/server_admin/index.html#_managing_organizations):
every tenant is an organization in the `mijnbureau` realm, and users are linked to a
tenant through organization membership and e-mail domain.

This page describes what MijnBureau configures, what the applications do and do not
enforce, and how to add a tenant. For connecting a tenant's own identity provider, see
[Identity federation](./identity-federation.md).

## How tenancy is modelled

| Layer          | Tenant boundary                                                   |
| -------------- | ----------------------------------------------------------------- |
| Identity       | Keycloak organization in the `mijnbureau` realm                   |
| Users          | Organization members (managed or unmanaged)                       |
| Routing        | Organization domains, used for domain-based IdP routing and login |
| Authentication | Optional per-organization identity providers                      |
| Applications   | No tenant boundary; all users share the same application data     |

MijnBureau does **not** deploy one realm or one set of applications per tenant. A single
realm keeps single sign-on across Chat, Docs, Drive, Meet, Mail and the other
applications working, which would break if every tenant had its own realm.

## What MijnBureau configures

The organization is defined in `helmfile/environments/default/authentication.yaml.gotmpl`:

```yaml
authentication:
  organization:
    name: "Mijn Bureau"
    alias: "mijnbureau"
    description: "Demo organization; all seeded demo users are members."
    # Defaults to global.domain when left empty
    domain: ~
```

`helmfile/apps/keycloak/values-keycloak-config-cli.yaml.gotmpl` renders this object into
the realm import and enables the feature on the realm:

```json
{
  "realm": "mijnbureau",
  "organizationsEnabled": true,
  "organizations": [
    {
      "name": "Mijn Bureau",
      "alias": "mijnbureau",
      "description": "Demo organization; all seeded demo users are members.",
      "enabled": true,
      "domains": [{ "name": "example.com", "verified": true }],
      "members": [{ "username": "johndoe" }]
    }
  ]
}
```

Two limitations are important:

- The `organizations` block is only rendered when the environment is `demo`. The
  `production` and `default` environments enable organizations on the realm but seed none.
- `authentication.organization` is a single object, so the chart can seed exactly one
  organization. Additional tenants must be added to the realm import (see
  [Adding a tenant](#adding-a-tenant)).

## What organizations control

- **Domains and routing.** `domains[].name` maps an e-mail domain to an organization.
  When a user enters an e-mail address on the login page, Keycloak resolves the domain to
  an organization and shows that organization's identity providers. Set
  `domains[].autoRedirect` to skip the login page and go straight to the provider.
- **Membership.** Organization members are regular realm users with a membership record.
  Managed members are created by Keycloak; unmanaged members are existing realm users
  that were added to the organization.
- **Identity providers.** An identity provider can be linked to an organization. Users
  authenticating through a linked provider join the organization automatically. See
  [Identity federation](./identity-federation.md).
- **Groups and roles.** Organizations have their own group tree and roles, which are
  mapped into tokens when the `organization` client scope is used.
- **Audit.** Membership and organization changes appear in the realm's admin events
  (`adminEventsEnabled: true`), which Keycloak retains for 30 days. MijnBureau does not
  ship an event exporter; forwarding events to a SIEM requires a separate listener.

## What is not enforced

Multi-tenancy in MijnBureau is currently **identity-level**, not data-level:

- **No application-level isolation.** Docs, Drive, Chat, Mail and the other applications
  are shared by all organization members. A member of tenant A can share a document with
  a member of tenant B, and search results are not filtered by tenant.
- **No tenant claim in tokens by default.** `organization` exists as an _optional_
  client scope in the realm. MijnBureau's clients use their default scopes, so access
  tokens contain no organization claim. To emit one, assign the `organization` scope (or
  a custom scope with an `oidc-organization-membership-mapper`) to a client and have the
  client request it.
- **No per-tenant quotas or namespaces.** Applications, databases and object storage are
  deployed once per environment.

## Tenant isolation with data sharing (planned)

Sharing data between tenants while keeping every tenant's data isolated needs more than an
organization in a shared installation. That model requires:

1. **A full MijnBureau installation per organization** — its own applications, databases,
   object storage, domain and URLs. Each installation is an independent tenant environment;
   there is no shared application data between them.
2. **Organization-aware routing in the Bureaublad.** A user who belongs to more than one
   organization must be sent to the correct installation. The Bureaublad needs additional
   logic to resolve the user's organization and redirect the user to that organization's
   Bureaublad endpoint (and from there to the tenant-specific applications) instead of
   always landing on the installation it was started from.
3. **Explicit cross-tenant sharing.** If documents or files must be shared across those
   installations, the sharing mechanism has to be designed per application; a shared
   Keycloak realm alone does not make the applications share data safely.

This is **not implemented** and is planned for the future. Until then:

- Use organizations in a single installation for identity-level tenancy only (shared
  application data).
- Use separate installations per organization if data must not be mixed, accepting that
  users work in one installation at a time and that the Bureaublad does not yet route them
  between installations.

## Adding a tenant

### Through the admin console

1. Open `https://<global.hostname.keycloak>.<global.domain>/admin/` and select the
   `mijnbureau` realm.
2. Go to **Manage → Organizations → Create organization**, then add the domain(s) and
   members.
3. If the tenant uses its own identity provider, link it on the organization's
   **Identity providers** tab.

Changes made in the console survive restarts, but are not part of the realm import and
will not be recreated on a fresh install.

### Through the realm import

For reproducible installs, add the organization to the realm import in
`helmfile/apps/keycloak/values-keycloak-config-cli.yaml.gotmpl`. The `organizations`
array accepts multiple entries, so this is also the way to seed several tenants:

```json
"organizations": [
  {
    "name": "Mijn Bureau",
    "alias": "mijnbureau",
    "description": "Internal organisation",
    "enabled": true,
    "domains": [{ "name": "example.com", "verified": true }],
    "members": [{ "username": "johndoe" }, { "username": "janedoe" }]
  },
  {
    "name": "Partner B.V.",
    "alias": "partner-bv",
    "description": "External partner",
    "enabled": true,
    "domains": [{ "name": "partner.example", "verified": false }],
    "members": []
  }
]
```

Keep the block inside the `{{- if eq .Environment.Name "demo" }}` guard, or move it out
of the guard when seeding tenants in another environment. Members referenced by
`username` must already exist in the realm; demo users come from the `user` list, other
environments need users from an identity provider or a directory federation.

`keycloak-config-cli` reconciles the declared organizations on every deploy. Removing an
organization from the array does not delete it from Keycloak; delete it in the console if
that is intended.

## Verifying

Use the bundled Keycloak admin CLI from inside the pod:

```bash
kubectl -n mijnbureau-keycloak exec -it keycloak-0 -- \
  /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080 --realm master \
  --user admin --password "$(kubectl -n mijnbureau-keycloak get secret keycloak-keycloak \
  -o jsonpath='{.data.admin-password}' | base64 -d)"

kubectl -n mijnbureau-keycloak exec keycloak-0 -- \
  /opt/keycloak/bin/kcadm.sh get organizations -r mijnbureau

kubectl -n mijnbureau-keycloak exec keycloak-0 -- \
  /opt/keycloak/bin/kcadm.sh get organizations/<alias-or-id>/members -r mijnbureau
```

To confirm a user ends up in the right tenant, log in with an e-mail address on the
organization's domain and check the membership again.

## Operational notes

- **Domain verification.** `verified: true` claims the domain for the organization.
  Two organizations cannot claim the same domain. Use `verified: false` for domains you
  do not control, and remember that Keycloak will not route unverified domains
  automatically.
- **Invitations need SMTP.** Organization invitations and e-mail verification use the
  realm SMTP settings from `smtp.*` in the environment values. Without SMTP, invitations
  cannot be delivered and members must be added manually.
- **Alias is the stable identifier.** Changing an organization alias breaks linked
  identity providers and external references; rename the display name instead.
- **One domain, one tenant.** Users with the same e-mail domain are expected to belong to
  the same organization. Mixed-domain tenants need multiple `domains` entries.
