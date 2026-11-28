# ADR-MB-018: Identity and tenancy model

## Status

Accepted

## Context

The suite consists of fourteen OIDC clients across Chat, Meet, Docs, Drive, Mail, Calendar,
Projects, People, Dictaphone, Conversations, Bureaublad and the Matrix Authentication
Service. Customers asked for support for multiple organisations in one deployment, and
most already have an identity provider of their own.

Two extremes were considered: one realm and one deployment per tenant, or a shared realm
with organization-based tenancy. Separate realms break single sign-on and duplicate every
client registration. Application-level data isolation would require changes in every
upstream product.

## Decision

We will run one Keycloak realm (`mijnbureau`) per environment and model tenants as
[Keycloak organizations](https://www.keycloak.org/docs/latest/server_admin/index.html#_managing_organizations).

- Organizations own e-mail domains, membership, groups and optional per-tenant identity
  providers.
- External identity providers are **brokered** into the realm (Option A in the identity
  federation documentation). Replacing Keycloak entirely remains possible but is a
  deployment-specific choice, not the supported default.
- Tenant isolation is at the identity layer only. Applications share data; a hard tenant
  boundary with cross-tenant data sharing requires a **separate MijnBureau installation per
  organization**. Routing users to the installation of their organization (including
  additional Bureaublad logic) is planned for the future and not implemented.
- The `organization` client scope is optional, so tokens do not carry tenant context unless
  a client opts in.

## Consequences

**Pros:**

- ✅ Single sign-on works across all applications for every tenant.
- ✅ One place to add a tenant, its domain and its identity provider.
- ✅ Upstream products stay unmodified and update independently.

**Cons:**

- ❌ No application-level data isolation; sharing across organizations is possible.
- ❌ Applications cannot make authorization decisions per tenant until they consume the
  organization claim.
- ❌ All tenants share quotas, storage classes and backup schedules.
- ❌ Replacing Keycloak requires recreating every client and secret in the external
  provider.
