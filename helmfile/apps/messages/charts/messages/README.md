# Messages

Helm chart for the [LaSuite Messages](https://github.com/suitenumerique/messages)
collaborative inbox.

## Components

| Component | Workload                                                              |
| --------- | --------------------------------------------------------------------- |
| Backend   | Django API (gunicorn)                                                 |
| Worker    | Celery worker and beat scheduler                                      |
| Frontend  | React SPA served by Caddy                                             |
| MTA       | Inbound SMTP server (`pymta`)                                         |
| Jobs      | Database migrations, superuser, mail-domain bootstrap and bucket CORS |

## Required values

| Value                    | Description                                     |
| ------------------------ | ----------------------------------------------- |
| `backend.secretKey`      | Django secret key                               |
| `backend.saltKey`        | Fernet salt for encrypted model fields          |
| `backend.mdaApiSecret`   | Shared secret between MTA and API               |
| `externalDatabase.*`     | PostgreSQL connection                           |
| `externalRedis.*`        | Valkey connection                               |
| `externalOpenSearch.url` | OpenSearch endpoint                             |
| `externalObjectStore.*`  | S3/MinIO endpoint, credentials and bucket names |
| `authentication.*`       | OIDC endpoints and client credentials           |
| `ingress.hostname`       | Public web hostname                             |
| `mta.service.*`          | Public SMTP service                             |

The MTA service is a `LoadBalancer` by default. Point the MX records at its public address
and open TCP port 25.

The chart expects the `common` chart from `../../../common/charts/common`. Run
`helm dependency build` before packaging.

## Parameters

| Parameter             | Description                                                                |
| --------------------- | -------------------------------------------------------------------------- |
| `global`              | Global parameters shared with subcharts                                    |
| `kubeVersion`         | Override Kubernetes version reported by `.Capabilities`                    |
| `apiVersions`         | Override Kubernetes API versions reported by `.Capabilities`               |
| `nameOverride`        | String to partially override `common.names.name`                           |
| `fullnameOverride`    | String to fully override `common.names.fullname`                           |
| `namespaceOverride`   | String to fully override `common.names.namespace`                          |
| `commonLabels`        | Labels to add to all deployed objects                                      |
| `commonAnnotations`   | Annotations to add to all deployed objects                                 |
| `clusterDomain`       | Kubernetes cluster domain name                                             |
| `extraDeploy`         | Array of extra objects to deploy with the release                          |
| `diagnosticMode`      | Diagnostic mode to debug startup issues                                    |
| `cluster`             | Cluster routing configuration (populated by shared values)                 |
| `messages`            | Shared pod settings (sidecars, init containers)                            |
| `backend`             | Django REST API (gunicorn)                                                 |
| `worker`              | Celery worker and beat scheduler                                           |
| `frontend`            | React single-page application and Caddy reverse proxy                      |
| `mta`                 | Inbound SMTP server that validates recipients and delivers mail to the API |
| `job`                 | Database migration and bootstrap jobs                                      |
| `service`             | Traffic exposure parameters                                                |
| `ingress`             | Public hostname and TLS settings                                           |
| `networkPolicy`       | Network policy parameters                                                  |
| `serviceAccount`      | Service account parameters                                                 |
| `externalRedis`       | Valkey connection                                                          |
| `externalDatabase`    | PostgreSQL connection                                                      |
| `externalOpenSearch`  | OpenSearch endpoint                                                        |
| `externalObjectStore` | S3/MinIO endpoint, credentials and bucket names                            |
| `authentication`      | OIDC endpoints and client credentials                                      |
| `superuser`           | Initial superuser credentials                                              |
| `bootstrap`           | Mail-domain bootstrap and bucket CORS bootstrap                            |
