# Bureaublad

MijnBureau supplies an installation of [Bureaublad](https://github.com/MinBZK/bureaublad). Bureaublad is a flexible dashboard application that aggregates information from multiple open-source components into a unified interface. Users can access essential tools and data from a single location without needing to switch between different applications.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                       | Description                                          |
| ------------------------------------------ | ---------------------------------------------------- |
| `global.domain`                            | The domain name of your MijnBureau instance          |
| `global.hostname.bureaublad`               | The name of the subdomain for the bureaublad client  |
| `application.bureaublad.enabled`           | Enable bureaublad for your MijnBureau implementation |
| `application.bureaublad.namespace`         | The Kubernetes namespace name                        |
| `authentication.client.bureaublad.*`       | OIDC client settings for bureaublad.                 |
| `tls.bureaublad.*`                         | The TLS settings for bureaublad                      |
| `resource.bureaublad.*`                    | Resources for bureaublad                             |
| `autoscaling.horizontal.bureaublad.*`      | Autoscaling for bureaublad.                          |
| `container.bureaublad.*`                   | Container selection                                  |
| `application.bureaublad.backend.secretKey` | Backend Django secret key                            |
| `ai.llm.*`                                 | AI used by bureaublad                                |

## Global search

When [Find](./find.md) is enabled (`application.find.enabled`), Bureaublad shows a
search bar that searches all enabled La Suite services (Docs and Drive today) via the
Find API. The backend exchanges the user's OIDC access token with
[Menshen](https://github.com/suitenumerique/menshen) (RFC 8693 token exchange) and
proxies the query to Find; every result links through to its document in Docs or Drive.

The helm values wire `FIND_URL`, `FIND_AUDIENCE`, `FIND_SEARCH_SCOPE`,
`MENSHEN_URL`, `MENSHEN_CLIENT_ID` and `MENSHEN_CLIENT_SECRET` automatically. The
bureaublad rule in Menshen grants `find:docs:search` and `find:drive:search` via
plain scope grants (`openid` source scope) instead of an action scope, because
Menshen actions can only yield one granted scope per target in the current versions.
