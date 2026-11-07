# Dictaphone

MijnBureau supplies an installation of [Dictaphone](https://github.com/suitenumerique/dictaphone),
also known as Assistant Transcripts. It is the transcription and meeting workflow application
from LaSuite. The backend is a Django application with Celery workers, the frontend is a
React single-page application, and audio extraction runs in dedicated transcoding and
validation workers.

## Configuration

To configure this solution, you can override the default settings for your environment. The
defaults are located in the folder `helmfile/environments/default`.

| Name                                      | Description                                             |
| ----------------------------------------- | ------------------------------------------------------- |
| `global.domain`                           | The domain name of your MijnBureau instance             |
| `global.hostname.dictaphone`              | The subdomain of the Dictaphone frontend                |
| `global.hostname.dictaphone-minio`        | The subdomain used for pre-signed object storage URLs   |
| `application.dictaphone.enabled`          | Enable Dictaphone                                       |
| `application.dictaphone.namespace`        | The Kubernetes namespace name                           |
| `application.dictaphone.secretKey`        | Django secret key                                       |
| `application.dictaphone.jwtSigningKey`    | JWT signing key                                         |
| `application.dictaphone.audioExtractor.*` | Internal audio worker tokens                            |
| `ai.dictaphone.*`                          | Optional external transcription service                 |
| `authentication.client.dictaphone.*`      | OIDC client credentials                                 |
| `database.dictaphone.*`                   | PostgreSQL connection details                           |
| `cache.dictaphone.*`                      | Redis connection details                                |
| `objectstore.dictaphone.*`                | MinIO bucket and credentials                            |
| `tls.dictaphone.*`                        | TLS settings                                            |
| `pvc.dictaphone.*`                        | Storage requirements for PostgreSQL, Redis and MinIO    |
| `resource.dictaphone.*`                   | Resources for each component                            |
| `autoscaling.horizontal.dictaphone.*`     | Autoscaling for the backend, frontend and Celery worker |
| `container.dictaphone_*`                  | Container image selection                               |
| `secret.dictaphone.*`                     | Django superuser credentials                            |

## AI transcription

Dictaphone sends transcription jobs to an external service compatible with the Meeting
Summary API. Set `ai.dictaphone.serviceUrl` to the service endpoint and provide
matching API keys through `ai.dictaphone.serviceApiKey` and
`ai.dictaphone.webhookApiKey`. When no AI service is configured, recordings and
transcripts can still be managed, but new transcription jobs cannot be processed.

## More information

- [Upstream repository](https://github.com/suitenumerique/dictaphone)
- [Public instance](https://transcripts.numerique.gouv.fr/)
