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
| `projects`          | Projects application configuration                                    |
| `authentication`    | OpenID Connect configuration                                          |
| `externalRedis`     | External Redis configuration                                          |
| `externalMinio`     | External S3-compatible object storage configuration                   |
| `smtp`              | Email notifications configuration                                     |
| `service`           | Projects service parameters                                           |
| `networkPolicy`     | Network policy parameters                                             |
| `ingress`           | Projects ingress parameters                                           |
| `serviceAccount`    | Service account parameters                                            |
| `cluster`           | Kubernetes cluster routing configuration (populated by shared values) |
