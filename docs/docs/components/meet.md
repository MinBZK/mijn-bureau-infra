# Meet

MijnBureau supplies an installation of [Meet](https://github.com/suitenumerique/meet). It is a video conferencing solutions that uses livekit.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                            | Description                                    |
| ------------------------------- | ---------------------------------------------- |
| `global.domain`                 | The domain name of your MijnBureau instance    |
| `global.hostname.meet`          | The name of the subdomain for the meet client  |
| `application.meet.enabled`      | Enable meet for your MijnBureau implementation |
| `application.meet.namespace`    | The Kubernetes namespace name                  |
| `authorization.meet.enabled`    | Enable meet for your MijnBureau implementation |
| `tls.meet.*`                    | The TLS settings for meet                      |
| `livekit.meet.*`                | Livekit connection                             |
| `pvc.meet.*`                    | storage requirements                           |
| `resources.meet.*`              | Resources for meet                             |
| `autoscaling.horizontal.meet.*` | Autoscaling for meet.                          |
| `container.meet.*`              | Container selection                            |
| `secret.meet.*`                 | Superuser credentials                          |

## More information

Meet is a video conferencing frontend for LiveKit. You can use the bundled LiveKit deployment within MijnBureau or connect to an external, hosted LiveKit instance. Please note that running video conferencing reliably on Kubernetes can be challenging due to networking and scaling requirements.

Currently, Firefox browser support is not fully stable. A known fix exists, but it has not yet been implemented in this deployment.

Meet offers several advanced features that are currently disabled, including:

- AI-powered meeting summaries
- SIP integration for video conferencing hardware
- AI agents for enhanced collaboration
- Live transcription

Id you need one of thesse solutions let us know and we will add it.

For more details or to request additional features, please refer to the official [Meet documentation](https://github.com/suitenumerique/meet).

    app.kubernetes.io/component: meet-backend
    app.kubernetes.io/instance: meet
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: meet
    app.kubernetes.io/part-of: meet
    app.kubernetes.io/version: 0.1.0

8000
app.kubernetes.io/component: meet-backend
app.kubernetes.io/instance: meet
app.kubernetes.io/name: meet
