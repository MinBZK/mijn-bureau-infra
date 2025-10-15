# Collabora

MijnBureau supplies an installation of [Collabora](https://www.collaboraonline.com/) based office. Collabora Online is a powerful online document editing suite. There is also a [desktop application](https://www.collaboraonline.com/collabora-office/) available

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                          | Description                                         |
| --------------------------------------------- | --------------------------------------------------- |
| `global.domain`                               | The domain name of your MijnBureau instance         |
| `global.hostname.collabora`                   | The name of the subdomain for the Collabora client  |
| `application.collabora.enabled`               | Enable Collabora for your MijnBureau implementation |
| `application.collabora.namespace`             | The Kubernetes namespace name                       |
| `application.collabora.enableInsecureCoolWSD` | Enable Insecure COOLWSD in Openshift                |
| `tls.collabora.*`                             | The TLS settings for Collabora                      |
| `autoscaling.horizontal.element.*`            | Autoscaling for Collabora.                          |
| `container.collabora.*`                       | Container selection                                 |
| `secret.collabora.*`                          | Authenticating with the Collabora                   |
| `security.collabora.*`                        | Enable security context only for openshift          |
| `security.default.*`                          | Enable default security context                     |

## Deploying Collabora on OpenShift

Deploying **Collabora** on OpenShift requires additional configuration in both the **SecurityContext** and the **Route**.

On OpenShift, make sure to enable:

- `application.collabora.enableInsecureCoolWSD`
- `security.collabora.podSecurityContext`
- `security.collabora.containerSecurityContext`
- `autoscaling`

## More information

- [Collabora Online for Kubernetes](https://sdk.collaboraonline.com/docs/installation/Kubernetes.html)
