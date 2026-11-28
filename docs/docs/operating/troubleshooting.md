---
sidebar_position: 130
---

# Troubleshooting

Failures in MijnBureau usually come from a handful of places: secrets that cannot
be rendered, storage that does not bind, routing that points at the wrong
Gateway, or a release that did not finish. Work through the layer that failed
before changing values.

## First look

```bash
helm list -A                                   # status of every release
helmfile -e <environment> status                # expected vs actual
kubectl get pods -A --field-selector=status.phase!=Running
kubectl get jobs -A                            # failed migrations and setup jobs
kubectl get events -A --sort-by=.lastTimestamp | tail -40
```

A release in `pending-upgrade` or `pending-install` blocks every later apply to
that release; deal with it first.

## Helmfile or rendering fails

| Symptom                                    | Cause                                    | Fix                                                                   |
| ------------------------------------------ | ---------------------------------------- | --------------------------------------------------------------------- |
| `requiredEnv "MIJNBUREAU_MASTER_PASSWORD"` | Variable not set for the render          | `export MIJNBUREAU_MASTER_PASSWORD=...` before every helmfile command |
| SOPS decryption error                      | `SOPS_AGE_KEY` missing or wrong          | Export the age key, or pass `-s "$SOPS_AGE_KEY"` to the test script   |
| `helmfile: command not found` in CI        | Plugins not installed                    | `helmfile init` once per machine                                      |
| Template error about a missing value       | Override removed a key the chart expects | Compare with `helmfile/environments/default/`                         |

## Release stuck in `pending-upgrade`

An interrupted `helmfile apply` leaves the release locked. Inspect and clear it:

```bash
helm history <release> -n <namespace>
helm rollback <release> <last-good-revision> -n <namespace>
```

Then re-apply. Never delete the release Secret to "fix" this; you lose Helm's
view of the resources.

## Users cannot sign in after a change

The most common cause is a changed `MIJNBUREAU_MASTER_PASSWORD`. It derives the
database passwords, Keycloak client secrets and admin logins; rotating it
invalidates all of them at once. Restore the previous value, or plan a full
credential rotation as described in [Secrets](./secrets/index.md).

If only one application fails, check its OIDC client in Keycloak and whether the
application can reach the identity provider through the default-deny
NetworkPolicy.

## Pods are fine but pages return 502 or 404

Check the routing layer, in this order:

1. The `Gateway` exists in the expected namespace and is `Accepted`.
2. The `HTTPRoute` references that Gateway. `cluster.gateway.name` is the Gateway
   _resource name_, not a namespace; the namespace comes from
   `cluster.gateway.namespace`.
3. The Service has endpoints: `kubectl -n <namespace> get endpoints <service>`.
4. The application's NetworkPolicy allows the ingress controller or Gateway.

## Certificates stay `Pending`

cert-manager HTTP01 needs the DNS record to resolve to the Gateway's address and
the `ClusterIssuer` to find the Gateway. A common mistake is a `parentRefs`
entry without a namespace: cert-manager then looks for the Gateway in each
Certificate's namespace while MijnBureau deploys per-app namespaces.

```bash
kubectl get challenges -A
kubectl describe challenge <name> -n <namespace>
kubectl get certificaterequests -A
```

Also confirm that cert-manager was installed with Gateway API support enabled and
restarted after the Gateway API CRDs were applied.

## PVCs stay `Pending`

- The requested `storageClassName` must exist. The demo environment expects the
  storage class created by the Fundament `BlockStorage` object.
- On a fresh Fundament cluster, check that the `DiskPool` references a disk that
  actually exists: a stale disk name yields no OSDs and no bound volumes.

```bash
kubectl get storageclass
kubectl get pvc -A | grep -v Bound
kubectl get disks
```

## A pod is blocked by networking

With default-deny ingress and egress enabled, only same-namespace traffic, DNS,
TCP/443 and the documented cross-namespace exceptions are allowed. Symptoms are
timeouts, not connection refused.

- Check whether the chart rendered its own NetworkPolicy for the port you need.
- Check that the peer namespace carries `kubernetes.io/metadata.name`.
- Mail submission uses port 25 and Keycloak uses 80/443; other ports need an
  explicit rule.

## Keycloak configuration job fails

`keycloak-config-cli` is sensitive to the Keycloak version and its root path.
Keycloak 26 redirects `/` with a 302; point the CLI at the correct base URL and
match the CLI release to the server version. The Job is safe to re-run after the
fix:

```bash
kubectl -n <namespace> logs job/keycloak-config-cli
```

## Database cluster is not ready

```bash
kubectl get clusters -A
kubectl describe cluster <name> -n <namespace>
kubectl cnpg status <name> -n <namespace>
```

CloudNativePG must be installed, including its CRDs, before Helmfile runs. A
cluster that cannot archive WAL is still usable but unprotected - see
[Backup and restore](./backup-restore.md).

## Application container crash-loops

```bash
kubectl -n <namespace> logs deploy/<app> --previous
kubectl -n <namespace> describe pod <pod>
```

Typical causes are a missing environment variable from an override, a secret
that was not synced by the External Secrets Operator, or a dependency that is not
reachable yet. Fix the cause; the pod recovers on its own.

## Getting help

Collect the output of the commands above before asking. The
[Matrix room](https://matrix.to/#/#mijnbureau:matrix.org) and the
[issue tracker](https://github.com/MinBZK/mijn-bureau-infra/issues) are the
fastest routes; include the release tag and the failing release name.
