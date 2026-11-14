# Keycloak

MijnBureau supplies an installation of [KeyCloak](https://www.keycloak.org/). Keycloak is an Identity and Access Management system. You can choice to use this component or your existing identity provider like microsoft Entra ID, Okta, GOogle Cloud idenity or OneLogin.

The bundled Helm-based deployment uses the [codecentric/keycloakx](https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx) chart with the official `quay.io/keycloak/keycloak` image. It does not require the Keycloak Operator. Realm/client/user configuration is applied by the upstream [adorsys/keycloak-config-cli](https://github.com/adorsys/keycloak-config-cli) image through the in-repo `keycloak-config-cli` chart.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                | Description                                  |
| ----------------------------------- | -------------------------------------------- |
| `global.domain`                     | The domain name of your MijnBureau instance  |
| `global.hostname.keycloak`          | The subdomain name                           |
| `application.keycloak.enabled`      | Enable keycloak                              |
| `application.keycloak.namespace`    | The Kubernetes namespace name                |
| `secret.keycloak.*`                 | Secrets for keycloak (admin user/password)   |
| `tls.keycloak.*`                    | The TLS settings                             |
| `authentication.client.*`           | The keycloak clients created                 |
| `authentication.oidc.*`             | The MijnBureau OIDC settings                 |
| `autoscaling.horizontal.keycloak.*` | Scaling settings                             |
| `container.keycloak.*`              | Container settings to overwrite              |
| `database.keycloak.*`               | Database configuration                       |
| `pvc.keycloak.*`                    | Storage configuration                        |
| `resource.keycloak.*`               | Resource configuration                       |
| `user.*`                            | Created users. Used in demo environment only |

The database (a CloudNativePG PostgreSQL cluster) is automatically created when running in the demo environment. For production you need to supply an external database via `database.keycloak.*`. Keycloak has no object store.

## Your own Identity provider

If you do not want to deploy keycloak but use your own disabled the application at `application.keycloak.enabled` and configure your own compatible OIDC provider in `authentication.oidc.*`
