# Projects

[Projects](https://github.com/suitenumerique/projects) is the collaborative project management application from LaSuite.

## Configuration

The chart expects the database, OIDC, SMTP and object storage settings to be provided by the MijnBureau Helmfile environment. The application image serves both the API and the frontend on port `1337`.

Key values:

- `projects.image` - `lasuite/projects` image.
- `externalDatabase` - PostgreSQL connection details.
- `externalRedis` - shared session and realtime Redis connection.
- `externalMinio` - S3-compatible object storage for uploads.
- `authentication` - OIDC issuer, claims and client credentials.
- `ingress` - public hostname and TLS settings.

Redis and object storage are required. Uploads are always stored in MinIO, local persistent storage is not supported, and `projects.autoscaling.hpa` can scale the deployment.
