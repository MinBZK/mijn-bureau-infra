# Find

MijnBureau supplies an installation of [Find](https://github.com/suitenumerique/find),
the global search service from LaSuite. Find indexes documents from the La Suite
applications (currently **Docs** and **Drive**) into OpenSearch — one index per
application — and lets their users search across all of them with their own access
rights enforced server-side.

Find ships together with [Menshen](https://github.com/suitenumerique/menshen), La
Suite's OAuth 2.0 Token Exchange server. Docs and Drive push documents to Find with a
per-service token; search and delete calls carry a user token exchanged (via Menshen)
from the user's Keycloak access token, so a user only ever sees documents they may
open. The exchange rules (`action:search-find-*` → `find:<service>:search/delete`) and
service credentials are provisioned declaratively by the `setup-services` hook job in
the `menshen` chart, and the `docs`/`drive` indexing services are registered by the
`register-services` hook job in the `find` chart.

## Status

Indexing into Find is active whenever `application.find.enabled` is set: every saved
Docs document and Drive item lands in the `find-docs` / `find-drive` OpenSearch
indices. Routing search **through** Docs/Drive is controlled by
`application.find.searchEnabled` (default `true`): the Docs integration enables the
`flag_find_full_text_search` / `flag_find_hybrid_search` waffle flags for all users,
and Drive sets `FEATURES_INDEXED_SEARCH=true`. This needs Menshen token-exchange
support in the deployed Docs/Drive images
([suitenumerique/docs#2920](https://github.com/suitenumerique/docs/issues/2920),
[suitenumerique/drive#934](https://github.com/suitenumerique/drive/issues/934)); on
images without it, set `searchEnabled` to `false` (Docs then falls back to title
search, Drive would return 500s on search while the flag is on).

## Configuration

Defaults are in the folder `helmfile/environments/default`.

| Name                                       | Description                                                           |
| ------------------------------------------ | --------------------------------------------------------------------- |
| `global.domain`                            | The domain name of your MijnBureau instance                           |
| `global.hostname.find`                     | Hostname of the Find API/admin                                        |
| `global.hostname.menshen`                  | Hostname of the Menshen token-exchange API/admin                      |
| `application.find.enabled`                 | Enable Find (and the Docs/Drive indexing integration)                 |
| `application.find.namespace`               | Namespace shared by Find and Menshen                                  |
| `application.find.searchEnabled`           | Route Docs/Drive search through Find (needs upstream token exchange)  |
| `application.find.opensearchIndexPrefix`   | Prefix of the OpenSearch indices (`find` by default)                  |
| `application.find.serviceTokens.docs`      | Find service token for Docs (50 chars, derived from master password)  |
| `application.find.serviceTokens.drive`     | Find service token for Drive (50 chars, derived from master password) |
| `application.find.menshen.enabled`         | Deploy Menshen                                                        |
| `application.find.menshen.clientSecrets.*` | Menshen client credentials for find/docs/drive                        |
| `authentication.client.menshen.*`          | Keycloak client Menshen introspects user tokens with                  |
| `database.find.*` / `database.menshen.*`   | PostgreSQL connection details                                         |
| `cache.find.*` / `cache.menshen.*`         | Valkey connection details                                             |
| `search.find.*`                            | OpenSearch endpoint; set `url` to use an external cluster             |
| `pvc.find.*` / `pvc.menshen.*`             | Storage for PostgreSQL, Valkey and OpenSearch                         |
| `resource.find.*` / `resource.menshen.*`   | Explicit resources per component                                      |
| `autoscaling.horizontal.find.*`            | Autoscaling for the Find backend                                      |
| `container.find`                           | Find image (`lasuite/find`, only a `main` tag is published upstream)  |
| `container.menshen`                        | Menshen image (`lasuite/menshen-backend`)                             |
| `container.opensearch`                     | OpenSearch image selection                                            |
| `secret.find.superUser.*`                  | Find Django admin user                                                |
| `secret.menshen.superUser.*`               | Menshen Django admin user                                             |

On the Keycloak side a `menshen` client is created and the `docs`/`drive` clients get
an `audience-menshen` protocol mapper so Menshen can introspect their access tokens.

## Components

| Component  | Description                                                                 |
| ---------- | --------------------------------------------------------------------------- |
| Find       | Django ASGI (uvicorn) API: `/api/v1.0/documents/{index,search,delete}/`     |
| Menshen    | Django ASGI OAuth 2.0 token exchange/introspection API under `/auth/token/` |
| PostgreSQL | Registered services + token hashes (Find); providers + rules (Menshen)      |
| Valkey     | Cache of Menshen introspection results (Find); cache/sessions (Menshen)     |
| OpenSearch | Document indices, single-node bundled deployment for the demo environment   |
