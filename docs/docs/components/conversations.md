# Conversations

MijnBureau supplies an installation of [Conversations](https://github.com/suitenumerique/conversations). Conversations is AI Assistant developer by LaSuite. It is still a prototype so use in production is not encouraged. To run the AI assistant you need an AI system available that supports the OpenAI chat endpoint. There are many companies that provide such systems, or you can run your own with ollama that is provided within this setup.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                     | Description                                             |
| ---------------------------------------- | ------------------------------------------------------- |
| `global.domain`                          | The domain name of your MijnBureau instance             |
| `global.hostname.conversations`          | The name of the subdomain for the conversations client  |
| `global.hostname.conversations-static`   | The name of the subdomain for the static assets         |
| `application.conversations.enabled`      | Enable conversations for your MijnBureau implementation |
| `application.conversations.namespace`    | The Kubernetes namespace name                           |
| `authentication.client.conversations.*`  | OIDC client configuration                               |
| `tls.conversations.*`                    | The TLS settings for conversations                      |
| `database.conversations.*`               | Database configuration                                  |
| `cache.conversations.*`                  | Cache (Valkey) configuration                            |
| `objectstore.conversations.*`            | Object store (S3/MinIO) configuration                   |
| `pvc.conversations.*`                    | storage requirements                                    |
| `resource.conversations.*`               | Resources for conversations                             |
| `autoscaling.horizontal.conversations.*` | Autoscaling for conversations.                          |
| `container.conversations_backend.*`      | Container selection (backend)                           |
| `container.conversations_frontend.*`     | Container selection (frontend)                          |
| `secret.conversations.*`                 | Superuser credentials                                   |
| `ai.llm.*`                               | AI used by conversations                                |

## More information

Conversations is an open-source AI chatbot designed to be simple, secure and privacy-friendly.
