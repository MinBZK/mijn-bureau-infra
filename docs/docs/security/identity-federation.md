---
sidebar_position: 7
---

# Identity federation

MijnBureau ships with Keycloak as its identity provider, but most organisations already
have an identity provider (Microsoft Entra ID, Okta, Google Workspace, an LDAP directory
or a government SSO). This page describes how to federate such a provider with
MijnBureau.

## Choose an approach

| Approach                    | What happens                                                                             | When to use it                                                                                   |
| --------------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| **A. Broker into Keycloak** | Keycloak stays the IdP of the applications and delegates login to the external provider  | Recommended when you want the MijnBureau suite, organizations and token exchange to keep working |
| **B. Replace Keycloak**     | Applications talk to the external provider directly; the Keycloak deployment is disabled | When you already run a fully OIDC-compatible IdP and do not need Keycloak features               |
| **C. Directory federation** | Keycloak keeps the user store but imports users from LDAP/Active Directory               | When accounts live in a directory and you want to keep Keycloak as the broker                    |

Approach A keeps `authentication.oidc.*` pointed at the in-cluster Keycloak, so no
application configuration changes. Approach B requires every application client to be
recreated at the external provider, including the token introspection that Meet, Docs and
Menshen depend on.

## Option A: broker an external IdP into Keycloak

### 1. Register a client at the external provider

Create an OIDC (or SAML) application at the external provider with the callback URL:

```
https://<global.hostname.keycloak>.<global.domain>/realms/mijnbureau/broker/<alias>/endpoint
```

`<alias>` is the identity provider alias you choose below. For SAML, the Assertion
Consumer Service URL is:

```
https://<global.hostname.keycloak>.<global.domain>/realms/mijnbureau/broker/<alias>/endpoint
```

and the entity ID / SP metadata is available from the same broker endpoint.

### 2. Add the identity provider to the realm import

Identity providers are declared next to `clients` in the realm JSON inside
`helmfile/apps/keycloak/values-keycloak-config-cli.yaml.gotmpl`:

```json
"identityProviders": [
  {
    "alias": "entra",
    "displayName": "Microsoft Entra ID",
    "providerId": "oidc",
    "enabled": true,
    "trustEmail": true,
    "storeToken": false,
    "firstBrokerLoginFlowAlias": "first broker login",
    "syncMode": "IMPORT",
    "config": {
      "issuer": "https://login.microsoftonline.com/<tenant-id>/v2.0",
      "authorizationUrl": "https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize",
      "tokenUrl": "https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token",
      "userInfoUrl": "https://graph.microsoft.com/oidc/userinfo",
      "jwksUrl": "https://login.microsoftonline.com/<tenant-id>/discovery/v2.0/keys",
      "clientId": "<client-id>",
      "clientSecret": "$(env:MB_IDP_ENTRA_CLIENT_SECRET)",
      "defaultScope": "openid profile email",
      "validateSignature": "true",
      "useJwksUrl": "true"
    }
  }
]
```

The secret is resolved by `keycloak-config-cli` variable substitution. Add it to the
`import.secrets` block in the same file so the value never appears in git:

```yaml
import:
  secrets:
    # ... existing entries ...
    MB_IDP_ENTRA_CLIENT_SECRET:
      { { requiredEnv "MB_IDP_ENTRA_CLIENT_SECRET" | quote } }
```

Export the variable before running Helmfile, next to `MIJNBUREAU_MASTER_PASSWORD`.

For SAML, use `"providerId": "saml"` and the SAML config keys instead:

```json
{
  "alias": "gov-sso",
  "displayName": "Government SSO",
  "providerId": "saml",
  "config": {
    "singleSignOnServiceUrl": "https://sso.example.gov/saml2/sso",
    "singleLogoutServiceUrl": "https://sso.example.gov/saml2/slo",
    "nameIDPolicyFormat": "urn:oasis:names:tc:SAML:2.0:nameid-format:transient",
    "validateSignature": "true",
    "signingCertificate": "$(env:MB_IDP_GOV_SIGNING_CERT)"
  }
}
```

### 3. Map claims

Keycloak maps `sub`, `preferred_username`, `email`, `given_name` and `family_name` from
standard OIDC claims automatically. If the provider uses different names, add identity
provider mappers to the same JSON:

```json
"identityProviderMappers": [
  {
    "name": "department",
    "identityProviderAlias": "entra",
    "identityProviderMapper": "oidc-user-attribute-idp-mapper",
    "config": {
      "claim": "department",
      "user.attribute": "department",
      "syncMode": "INHERIT"
    }
  }
]
```

MijnBureau's applications expect the claims configured in `authentication.oidc.claims`
(`preferred_username`, `name`, `given_name`, `family_name`, `email`,
`email_verified`). Make sure the external provider releases them; a missing or unverified
e-mail claim blocks account creation in the applications.

### 4. Link the provider to a tenant

To make users of this provider members of an organization automatically, link the alias
on the organization (see [Multi-tenancy](./multi-tenancy.md)):

```json
"organizations": [
  {
    "name": "Mijn Bureau",
    "alias": "mijnbureau",
    "enabled": true,
    "domains": [{ "name": "example.com", "verified": true }],
    "identityProviders": [{ "alias": "entra" }]
  }
]
```

With the domain and provider linked, Keycloak routes `@example.com` logins to Entra and
adds first-time users to the organization. Per-association options (for example
overriding the client ID per organization) are configured in the admin console on the
organization's **Identity providers** tab.

### 5. Decide what happens on first login

The `first broker login` flow links an incoming identity to an existing realm user by
e-mail, or creates a new user. The defaults are usually right. Change them only if you
need stricter matching:

- `syncMode: "IMPORT"` updates the local user on each login; `"FORCE"` also overwrites
  locally changed attributes.
- `trustEmail: true` skips e-mail verification because the provider already verified it.
  Only set this for providers you trust.
- Set `"linkOnly": true` to refuse creating unknown users and allow only pre-provisioned
  accounts.
- Set `"hideOnLogin": true` to remove the provider button from the login page and rely on
  domain-based routing only.

### 6. Apply and verify

```bash
export MIJNBUREAU_MASTER_PASSWORD=...
export MB_IDP_ENTRA_CLIENT_SECRET=...
helmfile -e demo apply

kubectl -n mijnbureau-keycloak exec keycloak-0 -- \
  /opt/keycloak/bin/kcadm.sh get identity-provider/instances -r mijnbureau
```

Then test three things: a login with an account from the provider, membership of the
expected organization, and single logout back to the application. Provider errors are
logged by Keycloak with the `org.keycloak.broker` category.

## Option B: replace Keycloak with an external IdP

Disable the bundled Keycloak and point MijnBureau at the external provider:

```yaml
application:
  keycloak:
    enabled: false

authentication:
  oidc:
    issuer: "https://id.example.com/realms/mijnbureau"
    discovery_endpoint: "https://id.example.com/realms/mijnbureau/.well-known/openid-configuration"
    authorization_endpoint: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/auth"
    token_endpoint: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/token"
    introspection_endpoint: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/token/introspect"
    userinfo_endpoint: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/userinfo"
    end_session_endpoint: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/logout"
    jwks_uri: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/certs"
```

Requirements and caveats:

### Clients to create

Every application is an OIDC client. You must recreate **all 14 clients** in the external
provider with exactly the client ID and secret that MijnBureau renders; any missing client
breaks that application, and a wrong secret breaks login for it.

| Client ID (`authentication.client.<name>.client_id`) | Used by                       | Redirect / callback URI                                                                              | Notes                                            |
| ---------------------------------------------------- | ----------------------------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `synapse`                                            | Chat (Synapse)                | `https://<synapse-host>/_synapse/client/oidc/callback`                                               | Backchannel logout required                      |
| `mas`                                                | Matrix Authentication Service | `https://<mas-host>/upstream/callback/01JCCW0000000000000000000K`                                    | Token exchange (RFC 8693)                        |
| `meet`                                               | Video conferencing            | `https://<meet-host>/*`                                                                              | Backchannel logout; introspection                |
| `conversations`                                      | AI Assistant                  | `https://<conversations-host>/*`                                                                     | Audiences: `docs`, `conversations`               |
| `drive`                                              | Drive                         | `https://<drive-host>/*`                                                                             | Audience: `menshen`                              |
| `docs`                                               | Docs / Notities               | `https://<docs-host>/*`                                                                              | Audience: `menshen`; introspection               |
| `projects`                                           | Projects                      | `https://<projects-host>/*`                                                                          |                                                  |
| `people`                                             | People                        | `https://<people-host>/*`                                                                            |                                                  |
| `calendars`                                          | Calendars                     | `https://<calendars-host>/*`                                                                         |                                                  |
| `dictaphone`                                         | Dictaphone                    | `https://<dictaphone-host>/*`                                                                        |                                                  |
| `messages`                                           | Messages (E-mail)             | `https://<messages-host>/api/v1.0/callback/` and `https://<messages-host>/api/v1.0/logout-callback/` | Audience: `messages`                             |
| `nextcloud`                                          | Nextcloud                     | `https://<nextcloud-host>/*`                                                                         | Backchannel logout; frontchannel logout required |
| `bureaublad`                                         | Bureaublad                    | `https://<bureaublad-host>/api/v1/auth/callback`                                                     | Audience: `menshen`; token exchange              |
| `menshen`                                            | Token exchange server         | `https://<menshen-host>/*`                                                                           | Service account (client credentials) enabled     |

Bureaublad's account menu (`REDIRECT_TO_ACCOUNT_PAGE`) links to the identity
provider's account console, which for Keycloak is `<issuer>/account/`. The bundled
realm enables the built-in `account` and `account-console` clients for this; an
external Keycloak must enable them too, otherwise that URL returns `404`.

Hostnames come from `global.hostname.*` and `global.domain`. The redirect URIs are
deliberately broad (`/*`) because the LaSuite applications use several callback paths;
keep them at least as broad at the provider or logins will fail with
`Invalid parameter: redirect_uri`.

### Client secrets

The secrets are not random: `authentication.client.*.client_secret` is derived from
`MIJNBUREAU_MASTER_PASSWORD` with the same expression for every client:

```text
derivePassword 1 "long" "$MIJNBUREAU_MASTER_PASSWORD" "keycloak" "<client>_client_secret" | sha1sum
```

Copy the rendered value for each client and use the **same** value as the client secret in
the external provider. You can read them from:

- the Keycloak admin console under **Clients → &lt;client&gt; → Credentials** on the current
  deployment, or
- `helmfile -e <env> template | grep -A2 client_secret`, or
- the `keycloak-config-cli` Secret in the cluster.

If you prefer your own secrets, override `authentication.client.<name>.client_secret` per
environment and use those values at the provider — but keep them consistent, because the
applications and the provider must agree.

### Required provider capabilities

- **Introspection is required.** Meet, Docs and Menshen call the introspection endpoint.
  Providers that only support self-contained JWTs (no `RFC 7662` introspection) will break
  those integrations.
- **No organizations.** Approach B loses Keycloak organizations, domain-based routing and
  per-tenant identity providers. Tenant modelling then lives entirely in the external
  provider.
- **Redirect URIs per application** must be registered at the provider, including the
  Bureaublad logout redirects listed in the client definitions.

## Option C: federate an LDAP or Active Directory

If users live in a directory but you want to keep Keycloak (and organizations), configure
user federation instead of brokering:

1. In the admin console, open **User federation → Add provider → LDAP**.
2. Set the connection URL, bind DN and bind credentials, then choose `EDIT_MODE`,
   `IMPORT_ENABLED` and the sync settings.
3. Configure the username/email mappers so the LDAP attributes match
   `authentication.oidc.claims`.

LDAP federation can also be declared in the realm import (`userFederation` in
`keycloak-config-cli`) if you prefer reproducible configuration; store the bind password
through `import.secrets` like the identity provider secret above.

## Troubleshooting

| Symptom                                           | Likely cause                                                                                             |
| ------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `Invalid parameter: redirect_uri` at the provider | Callback URL does not match the broker endpoint; check `global.hostname.keycloak` and `global.domain`    |
| `invalid_client` / `unauthorized_client`          | Client ID or secret mismatch; the secret in `import.secrets` was not exported before `helmfile apply`    |
| Login succeeds but no organization membership     | Provider is not linked to the organization, or the domain is unverified                                  |
| Provider button missing on the login page         | `hideOnLogin: true`, or the provider is disabled                                                         |
| User is asked to link an existing account         | Provider e-mail is not verified and `trustEmail` is `false`                                              |
| Application loops back to login                   | `email_verified` is missing from the token, or the claim names do not match `authentication.oidc.claims` |
| Meet/Docs cannot introspect tokens                | External provider has no introspection endpoint (only relevant for approach B)                           |
