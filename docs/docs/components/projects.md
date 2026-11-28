---
sidebar_position: 85
---

# Projects

_Where this fits: this page covers deployment. How to use it: [Projects](../user-guide/projects.md)._

MijnBureau supplies an installation of [Projects](https://github.com/suitenumerique/projects),
the collaborative project management application from LaSuite. Teams keep plans, pages and
tasks in one workspace, with members and roles managed through Keycloak.

The chart deploys a single application container behind a Service. Application data lives
in PostgreSQL; uploaded files go to the S3-compatible object store, and Valkey provides the
cache. In the demo environment all three are deployed with the application; production
expects external services.

## Configuration

To configure this solution, you can override the default settings for your environment. The
defaults are located in the folder `helmfile/environments/default`.

| Name                                | Description                                                              |
| ----------------------------------- | ------------------------------------------------------------------------ |
| `global.domain`                     | The domain name of your MijnBureau instance                              |
| `global.hostname.projects`          | The subdomain of the Projects frontend and API                           |
| `application.projects.enabled`      | Enable Projects                                                          |
| `application.projects.namespace`    | The Kubernetes namespace name                                            |
| `application.projects.secretKey`    | Django secret key                                                        |
| `application.projects.theme`        | Theme override (favicon, colours, fonts, header, footer, feedback links) |
| `authentication.client.projects.*`  | OIDC client credentials                                                  |
| `database.projects.*`               | PostgreSQL connection details                                            |
| `cache.projects.*`                  | Valkey connection details                                                |
| `objectstorage.projects.*`          | S3-compatible object storage                                             |
| `pvc.projects.*`                    | Storage requirements for PostgreSQL and Valkey                           |
| `resource.projects.*`               | Resources for the application                                            |
| `autoscaling.horizontal.projects.*` | Autoscaling for the application                                          |
| `container.projects_*`              | Container image selection                                                |

An empty `theme` keeps the upstream default; setting it replaces the branding that
Bureaublad and the other applications share.

## Components

| Component   | Description                                                |
| ----------- | ---------------------------------------------------------- |
| Application | Django API and React frontend served by the same pod       |
| HPA         | Horizontal autoscaling for the application                 |
| Service     | Cluster-internal entry point used by the Ingress/HTTPRoute |

Projects is marked **beta** in the Bureaublad while the upstream project stabilises.

## More information

- [Upstream repository](https://github.com/suitenumerique/projects)
- [Shared datastores](../operating/datastores/index.md)
