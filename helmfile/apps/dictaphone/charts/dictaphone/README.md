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
