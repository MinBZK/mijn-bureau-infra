# People and teams

MijnBureau includes **People**, the team and contact directory from LaSuite. It answers
questions such as "who is in this team", "what is their role" and "which mail domain do
they belong to", and it provides the contact data other applications use.

People is disabled by default (`application.people.enabled: false`) because most
deployments start with the identity provider as the source of truth. Enable it when users
need a shared directory with teams, roles and contact details.

It is currenlty still in alpha, and not fully tested.

## What you can do

- Browse people and teams within the organization.
- Maintain team membership and roles.
- Manage mail domains and their access.
- Share contact details with the rest of the suite through OIDC.

## Relation to identity

People is not an identity provider. Users authenticate through Keycloak; People stores the
directory information around those accounts. With Keycloak organizations, the organization
defines the tenant boundary and People describes the teams inside it.

- [Multi-tenancy and organizations](../security/multi-tenancy.md)
- [People upstream repository](https://github.com/suitenumerique/people)
