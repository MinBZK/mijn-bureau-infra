# ZAD-compatible branch

**This file only exists on the `zad-compatible` branch. It is not part of upstream `main`.**

`zad-compatible` is a long-lived integration branch that tracks
`origin/main` and adds the changes needed to release MijnBureau on our ZAD
platform. Upstream `main` assumes infrastructure defaults that ZAD does not
provide, so without these patches a release either fails to start or cannot
be migrated between clusters.

Do not delete this branch, and do not merge `zad-compatible` into `main` —
the individual patches go upstream as separate pull requests (see
[Upstream status](#upstream-status)).

## Why it exists

| ZAD reality | What upstream assumes |
| --- | --- |
| Managed Redis with the `default` ACL user disabled; a named ACL user is required | Every Redis URL is hardcoded to `redis://default:…` |
| Managed PostgreSQL that does not hand out the `postgres` superuser role | The docs migration jobs connect as `postgres` |
| Nodes get drained during cluster migration | The docs backend PDB also selects Job pods, so eviction is refused forever |
| Pull secrets scoped per registry | A single pull secret is assumed to cover every docs image, docspec included |
| Releases are reconciled by ArgoCD | The docs job names carry a fresh timestamp on every render |
| ArgoCD renders offline with `helmfile template`, so `.Capabilities` is empty | OpenShift is detected at install time from the live cluster |
| Deployments set extra env vars through their own values | The docs app has no route from a values key to `backend.extraEnvVars` |

## What is on this branch

Eight commits on top of `origin/main`.

### 1. Configurable Redis ACL username

`✨(other) allow configurable Redis ACL username for all apps`

Adds an optional username to the Redis wiring of **docs, drive, meet, grist,
conversations, openproject and bureaublad**.

Set it per app in your environment:

```yaml
cache:
  docs:
    username: "docs-acl"   # omit to keep "default"
```

The value is read with `dig "username" "default" .Values.cache.<app>`, so an
environment that does not set it renders exactly the same URL as before.
The charts of drive, meet, grist and conversations carry a matching
`externalRedis.username` value defaulting to `"default"`.

### 2. Configurable database admin user for the docs migration jobs

`🔧(docs) allow a configurable database admin user for migration jobs`

The `migrate` and `createsuperuser` jobs connected as a hardcoded `postgres`
superuser. Set instead:

```yaml
database:
  docs:
    adminuser: "docs_admin"      # falls back to "postgres"
    adminpassword: "…"           # falls back to database.docs.password
```

Docs v5.2.0 changed migration 0027 so it no longer requires a superuser
role, which is what makes a plain owner account sufficient.

> **The credentials replace, they do not append.** `DB_USER` and `DB_PASSWORD`
> are already in the common env, so appending the admin pair produced two
> entries with the same name. Kubernetes takes the last one and the job runs
> fine, but ArgoCD cannot build a strategic merge patch for a list with
> duplicate names: the Job stays `OutOfSync` forever and, with `Replace=true`
> and `selfHeal`, is re-created in a loop every reconcile. The migrate job is
> therefore rendered from a scope with both keys dropped, so each name appears
> exactly once. Watch for this whenever a value is added to a job's env.

### 3. Backend PDB no longer selects Job pods

`🐛(docs) stop the backend PDB from selecting job pods`

The docs backend PodDisruptionBudget selects on
`app.kubernetes.io/component: backend`, which the `migrate`,
`createsuperuser` and cronjob pods carry too. Completed Job pods are counted
by the eviction API but can never become healthy, so the budget is
permanently unsatisfiable: **`kubectl drain` is refused and a cluster
migration cannot finish.**

The fix adds `app.kubernetes.io/workload-type` (`deployment` / `job` /
`cronjob`) to the backend pod templates and narrows the PDB selector to
`workload-type: deployment`.

Docs is the only app with this problem — drive, meet, conversations and
bureaublad give their jobs a distinct `component` label.

> **Operational note.** The Deployment's own `spec.selector` is untouched, so
> this does not hit the immutable-selector restriction on `helm upgrade`.
> But running pods only pick up the new label once the rollout has replaced
> them, and until then the PDB matches zero pods. Roll out first, let the
> rollout finish, then drain.

### 4. Own image pull secret for docspec

`🐛(docs) give docspec its own image pull secret`

The docspec image ships from `ghcr.io` while the other docs images come from
their own registry, but `global.imagePullSecrets` rendered a single secret
via `coalesce(docs, default)`. On a cluster where pull secrets are scoped per
registry — a per-registry proxy cache, for instance — the docspec pods fail
to pull with an auth error while every other pod starts fine.

`global.imagePullSecrets` is now a deduplicated list of the docs and docspec
secrets, each falling back to `container.default.imagePullSecret`:

```yaml
container:
  docspec:
    imagePullSecret: "ghcr-pull"   # omit to keep the docs/default secret
```

The kubelet simply tries every listed secret, so listing both is harmless.

### 5. Stable job release suffix

`🐛(docs) derive the job release suffix from the backend tag`

The docs job names were suffixed with `now | unixEpoch`, which made every
render unique. Under ArgoCD that means the application never reaches Synced
and the `migrate` and `createsuperuser` jobs re-run on **every** sync.

The suffix is now derived from `container.docs.backend.tag`, so jobs get a
fresh name exactly when the version changes. Re-applying a changed job spec
under the same name is already covered by the jobs' `Replace=true,Force=true`
sync options.

Unlike the other four, this patch is not opt-in: it changes the rendered job
names for every environment. That is deliberate — a timestamped name is
unusable under GitOps — but it is the one place where this branch diverges
from `main` without a key to turn it off.

### 6. Declare the OpenShift API so the upstream SCC adaptation fires

`🐛(docs) declare the openshift API so securityContext adaptation fires`

Every values file in the repo asks the bitnami-common chart to adapt the
securityContext for OpenShift the same way:

```yaml
global:
  compatibility:
    openshift:
      adaptSecurityContext: auto
```

`auto` resolves through `common.compatibility.isOpenshift`, which is a live
cluster lookup:

```gotmpl
{{- if .Capabilities.APIVersions.Has "security.openshift.io/v1" -}}
```

During `helm install` / `helmfile apply` against an OpenShift cluster that is
populated from the API server, `auto` fires, and `runAsUser`, `runAsGroup` and
`fsGroup` are stripped so the restricted-v2 SCC can assign its own IDs. That is
how upstream runs on OpenShift, and why upstream needs no OpenShift-specific
values at all.

**ArgoCD renders offline.** The rig-cluster CMP plugin runs

```sh
helmfile --file "$helmfile_name" $helmfile_args template --include-crds
```

with no cluster connection, so `.Capabilities` is empty, `auto` never fires, and
the `runAsUser: 1001` / `fsGroup: 1001` defaults from
`helmfile/environments/default/security.yaml.gotmpl` end up in the manifests.
The restricted-v2 SCC then refuses the pods.

The fix declares the API in `helmfile/apps/docs/helmfile-child.yaml.gotmpl`:

```yaml
apiVersions:
  - security.openshift.io/v1
```

`security.openshift.io/v1` is referenced in exactly one place in the whole
chart tree (`common.compatibility.isOpenshift`, which only feeds
`renderSecurityContext`), so this has no other effect than making the upstream
adaptation behave as it does during a live install.

> **This makes every render of the docs app behave as OpenShift**, `kind` and
> `demo` included. That is intentional for ZAD but is why the patch cannot go
> upstream as it stands — upstream would need the API list to come from an
> environment value.

### 7. Pass `backend.extraEnvVars` through to the docs chart

`✨(docs) pass backend.extraEnvVars through to the chart`

The docs chart supports `backend.extraEnvVars` and renders it *after* the
generated env list (`backend-deployment.yaml:106`), so a duplicate name there
overrides a generated value. But `helmfile/apps/docs/values.yaml.gotmpl` never
populated it, so the key was unreachable.

This is easy to get wrong, because the same key name exists at two layers. A
deployment's `helm-values` are handed to helmfile as `--state-values-file`,
which makes them **helmfile template values** (`.Values.*` inside a `.gotmpl`),
not helm chart values. Every key has to be forwarded by hand in
`values.yaml.gotmpl`; anything that is not simply evaporates, with no warning.
A deployment that set

```yaml
backend:
  extraEnvVars:
    - name: FRONTEND_SILENT_LOGIN_ENABLED
      value: "true"
```

got no error and no env var.

The patch forwards the key, defaulting to an empty list:

```gotmpl
{{- with dig "backend" "extraEnvVars" list .Values }}
extraEnvVars: {{ toYaml . | nindent 4 }}
{{- end }}
```

Note `dig` on `.Values` root rather than `.Values.backend`: helmfile renders
values files with `missingkey=error`, so touching an absent top-level key is a
hard failure for every environment that does not set it.

This is the one patch here that is genuinely upstreamable — it is opt-in and
renders nothing when the key is unset. Grist and openproject hardcode their own
`extraEnvVars` and would be unaffected.

### 8. Overridable `FRONTEND_JS_URL`

`✨(docs) allow FRONTEND_JS_URL to be overridden per deployment`

Upstream hardcodes a back-to-bureaublad button into every docs deployment:

```gotmpl
FRONTEND_JS_URL: "https://static-{{ .Values.global.hostname.docs }}.{{ .Values.global.domain }}/bureaublad-button.js"
```

A deployment that does not run bureaublad gets a button pointing at a host that
does not exist. The obvious workaround -- setting the name again through
`backend.extraEnvVars` -- is a trap: it adds a *second* `FRONTEND_JS_URL` entry.
Kubernetes takes the last one and the app behaves, but ArgoCD cannot build a
strategic merge patch for a list with duplicate names, and the whole
application goes `OutOfSync` with

```
The order in patch list ... doesn't match $setElementOrder list
```

So the value is made overridable in place instead:

```yaml
application:
  docs:
    frontend:
      jsUrl: ""      # omit to keep the bureaublad button
```

Read with `dig "jsUrl" <the upstream URL> .Values.application.docs.frontend`,
so an environment that does not set it renders exactly as before.

**General rule for this chart:** never re-declare an env name that
`values.yaml.gotmpl` already sets. Make the value overridable at its source.
`extraEnvVars` is only for names the chart does not set itself.

## Guarantee: a no-op without the new keys

Patches 1, 2, 4, 7 and 8 are written so that an environment setting none of the
new keys renders byte-identical manifests to plain `origin/main`. Patches 3, 5 and 6
change output unconditionally, by design: the `workload-type` labels, the job
name suffix, and the OpenShift securityContext adaptation.

Verified by rendering both revisions and diffing:

```bash
export MIJNBUREAU_MASTER_PASSWORD=test
git worktree add --detach /tmp/wt-main origin/main
for app in docs drive meet conversations bureaublad; do
  (cd /tmp/wt-main && helmfile -e demo template --selector name=$app > /tmp/main-$app.yaml)
  helmfile -e demo template --selector name=$app > /tmp/new-$app.yaml
  diff /tmp/main-$app.yaml /tmp/new-$app.yaml   # expect only workload-type labels,
                                               # the docs job name suffix, and for
                                               # docs the dropped runAsUser /
                                               # runAsGroup / fsGroup
done
git worktree remove /tmp/wt-main
```

Re-run this after every rebase.

## Gotcha: `null` no longer deletes a value

Upstream `fad9945` (PR #667, July 2026) changed
`helmfile/bases/environment.yaml.gotmpl` so that **every** environment now also
loads `helmfile/environments/default/*.yaml*`. Previously `default` and
`production` were empty at the environment level and the defaults only entered
through each app's own child helmfile.

The consequence is easy to miss: those defaults are now part of `.Values`, and
a `null` in the project's `--state-values-file` no longer deletes them — the
helmfile state merge treats null as "absent, do not override". A deployment
that switched something off with

```yaml
security:
  default:
    containerSecurityContext:
      runAsUser: null      # used to remove the key entirely
```

silently gets the upstream default back. This is exactly what patch 6 works
around; check any other `null`/`~` override in a deployment's values before
trusting it.

## Keeping the branch current

**Prefer re-applying over rebasing.** The patches are small (19 files, ~39
added lines) and touch code that upstream refactors regularly. Upstream
PR #625 moved credentials from ConfigMaps into a per-app `secret.yaml`,
which rewrote most of the lines this branch patches — resolving those
conflicts took longer than redoing the work.

```bash
git tag parked/zad-compatible-$(date +%F) zad-compatible
git format-patch origin/main..zad-compatible -o ../parked-patches/
git switch -c zad-compatible-next origin/main
# re-apply the eight changes, then diff against the parked patches
```

Useful check for whether upstream has drifted:

```bash
git grep -n "redis://default:" -- helmfile/
git grep -n 'DB_USER: "postgres"' -- helmfile/
git grep -n "now | unixEpoch" -- helmfile/
```

All three should return nothing on this branch. For patch 6, the check is the
other way round — this must return a hit:

```bash
git grep -n "security.openshift.io/v1" -- helmfile/apps/docs/helmfile-child.yaml.gotmpl
```

## Upstream status

| Change | Upstream |
| --- | --- |
| Redis ACL username | No PR has ever been opened |
| Docs DB admin user | No PR has ever been opened |
| PDB workload-type label | PR #377 closed unmerged, January 2026 |
| Docspec image pull secret | No PR has ever been opened |
| Stable job release suffix | No PR has ever been opened |
| OpenShift API declaration | Not upstreamable as it stands (see patch 6) |
| `backend.extraEnvVars` passthrough | Upstreamable as is; no PR opened yet |
| Overridable `FRONTEND_JS_URL` | Upstreamable as is; no PR opened yet |

Getting these merged upstream is the only way to retire this branch. Until
then every docs version bump requires re-applying the patches.

Unrelated but often confused with the above: the OIDC fullname fix
(`OIDC_USERINFO_FULLNAME_FIELDS` including `family_name`, needed for user
search) **was** merged upstream as PR #512 and is part of `main`. It does
not live on this branch.
