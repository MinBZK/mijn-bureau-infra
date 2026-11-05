# Projects

[Projects](https://github.com/suitenumerique/projects) is the collaborative project management application from LaSuite.

## Configuration

The chart expects the database, OIDC, SMTP and persistence settings to be provided by the MijnBureau Helmfile environment. The application image serves both the API and the frontend on port `1337`.

Key values:

- `projects.image` - `lasuite/projects` image.
- `externalDatabase` - PostgreSQL connection details.
- `externalRedis` - shared session and realtime Redis connection.
- `externalMinio` - S3-compatible object storage for uploads.
- `authentication` - OIDC issuer and client credentials.
- `persistence.public`, `persistence.backgrounds`, `persistence.attachments` - optional local upload storage when `projects.s3.enabled` is false.
- `ingress` - public hostname and TLS settings.

Redis and object storage are required for running more than one replica. When `projects.s3.enabled` is true the local PVCs are disabled, uploads are stored in MinIO, and `projects.autoscaling.hpa` can scale the deployment.
