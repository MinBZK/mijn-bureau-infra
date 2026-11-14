# Dictaphone

[Dictaphone](https://github.com/suitenumerique/dictaphone) (Assistant Transcripts) is the
transcription and meeting workflow application from LaSuite.

## Components

The chart deploys:

- a Django backend, its migration and superuser jobs, and maintenance CronJobs;
- a Celery worker;
- a static React frontend served by nginx;
- transcoding and validation audio extraction workers;
- a restricted S3 gateway used by the audio workers;
- PostgreSQL, Redis and MinIO connection wiring supplied by the MijnBureau Helmfile environment.

## Key values

- `backend.image`, `frontend.image`, `audioExtractor.image`, `s3Gateway.image` - component images.
- `externalDatabase` - PostgreSQL connection details.
- `externalRedis` - Redis connection details.
- `objectstore` - internal and public S3 endpoints, bucket and credentials.
- `authentication` - OIDC issuer and client credentials.
- `application.secretKey`, `application.jwtSigningKey` - Django and JWT signing secrets.
- `application.audioExtractor` - internal tokens shared with the audio workers.
- `application.ai` - optional external transcription service compatible with the Meeting Summary API. Configure it through `ai.dictaphone` in the MijnBureau environment.
- `ingress` - public hostname and TLS settings.

The frontend serves `/`, while `/api`, `/admin`, `/static` and `/external-api` are routed to
the backend. Pre-signed S3 URLs are generated against `objectstore.publicUrl`, which must
route to the MinIO service.

## Parameters

| Parameter           | Description                                                           |
| ------------------- | --------------------------------------------------------------------- |
| `global`            | Global parameters shared with subcharts                               |
| `kubeVersion`       | Override Kubernetes version reported by `.Capabilities`               |
| `nameOverride`      | String to partially override `common.names.name`                      |
| `fullnameOverride`  | String to fully override `common.names.fullname`                      |
| `namespaceOverride` | String to fully override `common.names.namespace`                     |
| `commonLabels`      | Labels to add to all deployed objects                                 |
| `commonAnnotations` | Annotations to add to all deployed objects                            |
| `clusterDomain`     | Kubernetes cluster domain name                                        |
| `extraDeploy`       | Array of extra objects to deploy with the release                     |
| `diagnosticMode`    | Diagnostic mode to debug startup issues                               |
| `backend`           | Dictaphone backend (Django) configuration                             |
| `frontend`          | Dictaphone frontend (static SPA served by nginx) configuration        |
| `celery`            | Dictaphone Celery worker configuration                                |
| `audioExtractor`    | Audio extraction workers (transcoding and validation)                 |
| `s3Gateway`         | Restricted S3 gateway used by the audio workers                       |
| `service`           | Backend and frontend service parameters                               |
| `ingress`           | Public hostname and TLS settings                                      |
| `externalDatabase`  | PostgreSQL connection details                                         |
| `externalRedis`     | Redis connection details                                              |
| `objectstore`       | Internal and public S3 endpoints, bucket and credentials              |
| `authentication`    | OIDC issuer and client credentials                                    |
| `application`       | Django/JWT secrets, superuser and audio worker tokens                 |
| `smtp`              | SMTP parameters                                                       |
| `jobs`              | Database migration and superuser jobs                                 |
| `cronJobs`          | Maintenance CronJobs                                                  |
| `serviceAccount`    | Service account parameters                                            |
| `cluster`           | Kubernetes cluster routing configuration (populated by shared values) |
