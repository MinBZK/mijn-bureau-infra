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
