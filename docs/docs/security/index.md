---
sidebar_position: 10
---

# Security

Security within MijnBureau is a collaborative effort involving multiple stakeholders, with primary responsibility shared between the `Service Integrator` and the MijnBureau suite.

In this section, we outline the specific responsibilities of each party and describe best practices for building and maintaining a secure system.

## Start here

| Topic                                     | Page                                                                    |
| ----------------------------------------- | ----------------------------------------------------------------------- |
| Who is responsible for what               | [Service integrator](./serviceintegrator.md)                            |
| What MijnBureau does about security       | [Mijn Bureau](./mijnbureau.md)                                          |
| Identity, SSO and user federation         | [Identity federation](./identity-federation.md)                         |
| Password, OTP and biometric assurance     | [Authentication assurance levels](./authentication-assurance-levels.md) |
| Separating tenants                        | [Multi-tenancy](./multi-tenancy.md)                                     |
| Upstream projects and their posture       | [Upstream products](./upstreamproducts.md)                              |
| Image digests, SBOMs, signatures and CVEs | [Supply chain](./supply-chain.md)                                       |
| DKIM, SPF, DMARC and mail reputation      | [Secure email setup](./email.md)                                        |

Operational security tasks - admin access, secrets, backups - live in
[Operating](../operating/index.md). Django admin interfaces are not publicly
routed; see
[Administration](../operating/administration.md#admin-surfaces-at-a-glance).
