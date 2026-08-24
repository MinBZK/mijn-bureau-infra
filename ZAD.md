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

## What is on this branch

Five commits on top of `origin/main`.

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

## Guarantee: a no-op without the new keys

Patches 1, 2 and 4 are written so that an environment setting none of the new
keys renders byte-identical manifests to plain `origin/main`. Patches 3 and 5
change output unconditionally, by design: the `workload-type` labels and the
job name suffix.

Verified by rendering both revisions and diffing:

```bash
export MIJNBUREAU_MASTER_PASSWORD=test
git worktree add --detach /tmp/wt-main origin/main
for app in docs drive meet conversations bureaublad; do
  (cd /tmp/wt-main && helmfile -e demo template --selector name=$app > /tmp/main-$app.yaml)
  helmfile -e demo template --selector name=$app > /tmp/new-$app.yaml
  diff /tmp/main-$app.yaml /tmp/new-$app.yaml   # expect only workload-type labels
                                               # and the docs job name suffix
done
git worktree remove /tmp/wt-main
```

Re-run this after every rebase.

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
# re-apply the five changes, then diff against the parked patches
```

Useful check for whether upstream has drifted:

```bash
git grep -n "redis://default:" -- helmfile/
git grep -n 'DB_USER: "postgres"' -- helmfile/
git grep -n "now | unixEpoch" -- helmfile/
```

Both should return nothing on this branch.

## Upstream status

| Change | Upstream |
| --- | --- |
| Redis ACL username | No PR has ever been opened |
| Docs DB admin user | No PR has ever been opened |
| PDB workload-type label | PR #377 closed unmerged, January 2026 |
| Docspec image pull secret | No PR has ever been opened |
| Stable job release suffix | No PR has ever been opened |

Getting these merged upstream is the only way to retire this branch. Until
then every docs version bump requires re-applying the patches.

Unrelated but often confused with the above: the OIDC fullname fix
(`OIDC_USERINFO_FULLNAME_FIELDS` including `family_name`, needed for user
search) **was** merged upstream as PR #512 and is part of `main`. It does
not live on this branch.
