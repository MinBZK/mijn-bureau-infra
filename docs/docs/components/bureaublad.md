# Bureaublad

MijnBureau supplies an installation of [Bureaublad](https://github.com/MinBZK/bureaublad). Bureaublad is a flexible dashboard application that aggregates information from multiple open-source components into a unified interface. Users can access essential tools and data from a single location without needing to switch between different applications.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                  | Description                                          |
| ------------------------------------- | ---------------------------------------------------- |
| `global.domain`                       | The domain name of your MijnBureau instance          |
| `global.hostname.bureaublad`          | The name of the subdomain for the bureaublad client  |
| `application.bureaublad.enabled`      | Enable bureaublad for your MijnBureau implementation |
| `application.bureaublad.namespace`    | The Kubernetes namespace name                        |
| `authentication.bureaublad.*`         | OIDC client settings for bureaublad.                 |
| `tls.bureaublad.*`                    | The TLS settings for bureaublad                      |
| `resource.bureaublad.*`               | Resources for bureaublad                             |
| `autoscaling.horizontal.bureaublad.*` | Autoscaling for bureaublad.                          |
| `container.bureaublad.*`              | Container selection                                  |
| `secret.bureaublad.*`                 | Superuser credentials                                |
| `ai.llm.*`                            | AI used by bureaublad                                |
