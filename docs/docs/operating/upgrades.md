---
sidebar_position: 120
---

# Upgrades and rollback

MijnBureau is upgraded by changing the versioned inputs in Git and re-applying
Helmfile. This page covers the order of operations, what to check afterwards,
and how to get back if a release misbehaves.

## What an upgrade changes

| Input                                                    | Changed by                 | Effect                         |
| -------------------------------------------------------- | -------------------------- | ------------------------------ |
| Container image tags                                     | updatecli pull requests    | New application versions       |
| Helm chart versions                                      | updatecli pull requests    | New templates, values and CRDs |
| Values in `helmfile/environments/`                       | You                        | Configuration changes          |
| Operator versions (CNPG, ESO, cert-manager, Gateway API) | You, or your platform team | Cluster-wide behaviour         |

The release tarball documents exactly which images a version deploys, including
digests and known CVEs. Check `containers.md` before upgrading, especially when a
release jumps several minor versions.

## Before you upgrade

1. **Read the release.** Review the generated [release pages](../releases/index.md)
   and the upstream release notes for every component that changes major
   version.
2. **Back up.** Take a Velero backup of the affected namespaces and confirm that
   CNPG WAL archiving is healthy. See [Backup and restore](./backup-restore.md).
3. **Render the diff.** Helmfile can show the change without applying it:

   ```bash
   helmfile -e <environment> diff
   ```

   Review anything that recreates a StatefulSet, changes a PVC size, or deletes a
   Secret.

4. **Check migrations.** LaSuite applications and Keycloak run database
   migrations on startup. A downgrade cannot reverse them; that is why rollback
   is a restore, not just a re-apply.

## Upgrade

```bash
helmfile -e <environment> apply
```

Apply one release at a time when you are unsure which component causes a
problem. Helmfile accepts `--selector name=<release>` to limit the scope.

Watch the rollout:

```bash
helm list -A
kubectl get pods -A --field-selector=status.phase!=Running
```

Jobs created by charts (migrations, Keycloak configuration, object-store setup)
must complete. A failed Job blocks the application even when all pods are
`Running`.

## Verify

- Sign in through Keycloak, then open one application per major component: Docs,
  Drive, Meet, Messages, Element.
- Check that background processing works: send a mail, start a transcription,
  join a meeting.
- Confirm certificate renewal and ingress routing are unchanged.
- Check the vulnerability delta in the release report if the upgrade was
  security-driven.

## Rollback

There are three levels, from cheapest to most destructive:

1. **Revert the commit and re-apply.** If the upgrade is a values or chart
   version change, reverting in Git and running `helmfile apply` returns to the
   previous rendered state.
2. **Roll back a single Helm release.** When Git is already correct but one
   release is broken:

   ```bash
   helm history <release> -n <namespace>
   helm rollback <release> <revision> -n <namespace>
   ```

   This is also how you clear a release stuck in `pending-upgrade`.

3. **Restore data.** Only needed when a migration changed the schema. Restore
   the database from the CNPG backup into a new cluster, point the application at
   it, and accept that writes after the recovery point are lost.

Rolling back images without rolling back the database schema is the classic way
to turn an incident into an outage. If the upgrade ran migrations, plan for a
restore.

## After the upgrade

- Remove any temporary overrides you added while debugging.
- Update the image digests in `images.lock.yaml` if you pin from the release.
- Delete completed migration Jobs only if your chart does not manage their
  lifecycle; otherwise leave them to Helm.
