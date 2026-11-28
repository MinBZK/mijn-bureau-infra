---
sidebar_position: 65
---

# Authentication assurance levels (ACR)

MijnBureau uses Keycloak's Authentication Context Class Reference (ACR) support to
express how strongly a user authenticated. Applications and administrators can require
a level before Keycloak issues a token.

| Level | Name        | Factors                                                                     |
| ----- | ----------- | --------------------------------------------------------------------------- |
| ACR1  | Basic       | Username and password                                                       |
| ACR2  | Substantial | ACR1 plus a one-time password (OTP)                                         |
| ACR3  | High        | ACR2 plus WebAuthn user verification (fingerprint, Touch ID, Windows Hello) |

The levels are cumulative. ACR3 always includes the password and OTP steps. The
`acr` claim in the access and ID tokens reports the level that was reached, and
`amr` reports the methods that were used.

ACR is about authentication assurance. It does not decide which documents, mail or
files a user may see. Authorization still comes from Keycloak roles, organizations
and the application's own permissions.

## How it is configured

All configuration lives in `helmfile/apps/keycloak/values-keycloak-config-cli.yaml.gotmpl`
and is driven by `authentication.acr` in `helmfile/environments/default/authentication.yaml.gotmpl`:

- The realm maps ACR values to numeric Levels of Authentication (`acr.loa.map`,
  rendered from `authentication.acr.levels`).
- The realm binds a step-up browser flow (`mijnbureau-browser`) that contains one
  conditional sub-flow per level. Keycloak only runs the sub-flows needed to reach
  the level requested by the client.
- Every OIDC client gets `default.acr.values` and `minimum.acr.value`, both defaulting
  to `1` (`authentication.acr.defaultLevel`). `default.acr.values` is what the client
  asks for when the application sends no `acr_values`; `minimum.acr.value` is the
  server-side floor that an application or user cannot lower.

```yaml
authentication:
  acr:
    defaultLevel: "1"
    levels:
      "1": 1
      "2": 2
      "3": 3
    maxAge:
      "1": 43200 # seconds a completed level stays valid in the SSO session
      "2": 43200
      "3": 3600
    clients: {}
    webauthn:
      userVerification: "required"
      attachment: "not specified"
      createTimeout: 0
```

## Require a level for an application

Add the client to `authentication.acr.clients`, using the key from
`authentication.client`:

```yaml
authentication:
  acr:
    clients:
      docs: "2"
      messages: "3"
```

Apply with `helmfile -e <environment> apply`. On the next login, Keycloak asks the
user for the missing factor and then issues a token with the matching `acr` claim.
A user who is already signed in is stepped up without re-entering the password.

The same setting is available in the Admin Console under **Clients** > select the
client > **Advanced**:

- **Default ACR Values**: the level the client requests when it sends none.
- **Minimum ACR Value**: the enforced floor. Use this one; default values alone can
  be overridden by an `acr_values` parameter in the login URL.

Set both to the same value. ACR values are per client, not per user or role: requiring
one level for administrators and another for regular users on the same application
needs a separate client.

## Enrolment

Enrolment happens inline. When a client requests ACR2 and the user has no OTP, the
login page shows the OTP setup. When it requests ACR3 and the user has no WebAuthn
credential, the login page shows the WebAuthn registration. This keeps first login
self-service, but it also means a user can register a credential during the same
login that requires it. Pre-enrol users through the Account Console if the credential
must exist before a level is granted.

Passkeys are a separate Keycloak feature. They replace the password at login instead
of adding a third factor, and they use a different credential type. Passkeys are
disabled; ACR3 uses the WebAuthn Authenticator with user verification required, so a
platform biometric (Touch ID, Windows Hello, phone fingerprint) satisfies the level.
Administrators may enable **WebAuthn Register** under **Authentication** > **Required
Actions** to let users enrol from the Account Console.

Set `authentication.acr.webauthn.attachment: "platform"` to reject USB/NFC security
keys. The default `not specified` accepts any WebAuthn authenticator, including
hardware keys without a biometric.

## Session behaviour

A completed level stays valid for the number of seconds in `authentication.acr.maxAge`.
The defaults give one OTP per 12 hour session (matching `ssoSessionMaxLifespan`) and
one WebAuthn verification per hour. Lower the values to re-prompt more often. A level
never steps down inside the same SSO session.

Because the level is stored on the session, a token issued at ACR3 remains valid until
it expires. Keep access token lifetimes at or below the level max age.

## Limitations

- `acr_values` in the login URL can be edited by the user. The `minimum.acr.value`
  client setting is what actually enforces a level. Applications that support step-up
  should still validate `acr` in the ID token, ideally with PAR or a request object.
- `minimum.acr.value` does not apply to direct access grants, service accounts,
  standard token exchange or JWT authorization grants. Exchanged tokens can carry
  `acr` 0 or 1 even when the browser session is ACR3. Do not validate `acr` on tokens
  obtained through token exchange (for example Bureaublad or Menshen introspection).
- Self-service password reset cannot reach a level above ACR1. Clients with a higher
  minimum reject the reset flow; reset the password through the Admin Console instead.
- A brokered identity provider (Entra ID, Okta and similar) does not automatically
  contribute a Keycloak level. The Keycloak sub-flows still run; map the external
  provider's own assurance in that provider if it must count.
- Native clients such as Element X sign in through the system browser. WebAuthn works
  on iOS and Android, but verify the flow before raising those clients above ACR1.

## Verifying

```bash
# Advertised ACR values
curl -s https://keycloak.<domain>/realms/mijnbureau/.well-known/openid-configuration \
  | jq '.acr_values_supported'

# Realm mapping, bound flow and per-client settings
kcadm.sh get realms/mijnbureau | jq '{browserFlow, attributes}'
kcadm.sh get clients -r mijnbureau --fields clientId,attributes | jq
```

To test a level, start an authorization request with `acr_values=2` (or an essential
`claims` request) and decode the ID token. The `acr` claim must contain the requested
value. A `prompt=none` request without a credential that satisfies the level returns
`unmet_authentication_requirements`.
