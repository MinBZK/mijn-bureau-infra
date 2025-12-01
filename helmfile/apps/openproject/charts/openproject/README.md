# Helm chart for OpenProject

This is the chart for OpenProject itself. It bootstraps an OpenProject instance, optionally with a PostgreSQL database and Memcached.

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0.0+
- PV provisioner support in the underlying infrastructure

## Helm chart Provenance and Integrity

We sign our chart using the [Helm Provenance and Integrity](https://helm.sh/docs/topics/provenance/) functionality. You can find the used public key here

- https://github.com/opf/helm-charts/blob/main/signing.key
- https://keys.openpgp.org/vks/v1/by-fingerprint/CB1CA0488A75B7471EA1B087CF56DD6A0AE260E5

We recommend using the [Helm GnuPG plugin](https://github.com/technosophos/helm-gpg). With it you can manually verify the signature like this:

```bash
helm repo add openproject https://charts.openproject.org
helm fetch --prov openproject/openproject
helm gpg verify openproject-*.tgz
```

## Installation

### Demo video

Below is a demo video on how to install OpenProject using the helm chart, including configuration for Let's Encrypt TLS certificate with cert-manager and ingress-nginx:

[![Helm Chart Demo Video](https://github.com/opf/helm-charts/assets/6114/84fed1bd-85b0-43a2-a943-c3db4dc44b80)](https://openproject-docs.s3.eu-central-1.amazonaws.com/videos/openproject-installation-kubernetes-helm-charts.mp4)

Accompanying README instructions for the demo video: [opf/helm-charts/demo](https://github.com/opf/helm-charts/tree/main/demo)

### Quick start

Add the OpenProject Helm repository:

```shell
helm repo add openproject https://charts.openproject.org
helm repo update
```

Install the OpenProject chart in a dedicated `openproject` namespace:

```shell
helm upgrade --create-namespace --namespace openproject --install openproject openproject/openproject
```

The namespace is optional, but we highly recommend it as it does make it easier to manage the resources created for OpenProject.

## Configuration

Configuration of the chart takes place through defined values, and a catch-all entry `environment` to provide all possible variables through ENV that OpenProject supports. To get more information about the possible values, please see [our guide on environment variables](https://www.openproject.org/docs/installation-and-operations/configuration/environment/).

### Available OpenProject specific helm values

We try to map the most common options to chart values directly for ease of use. The most common ones are listed here, feel free to extend available values [through a pull request](https://github.com/opf/helm-charts/).

#### OpenProject image and version

By default, the helm chart will target the latest stable major release. You can define a custom [supported docker tag](https://hub.docker.com/r/openproject/community/) using `image.tag`. Override container registry and repository using `image.registry` and `image.repository`, respectively.

Please make sure to use the `-slim` variant of OpenProject, as the all-in-one container is adding unnecessary services and will not work as expected with default options such as operating as a non-root user.

#### HTTPS mode

Regardless of the TLS mode of ingress, OpenProject needs to be told whether it's expected to run and return HTTPS responses (or generate correct links in mails, background jobs, etc.).
This will likely be true, even if OpenProject is not responsible for terminating TLS connections inside the deployment. It will cause OpenProject to output secure cookies, as well as other protection measures.

> [!CAUTION]
> If you're not terminating https anywhere in your stack, then set `openproject.https=false`. This is not recommended for production systems

#### Seed locale

By default, demo data and global names for types, statuses, etc. will be in English. If you wish to set a custom locale, set `openproject.seed_locale=XX`, where XX can be a two-character ISO code. For currently supported values, see the `OPENPROJECT_AVAILABLE__LANGUAGES` default value in the [environment guide](https://www.openproject.org/docs/installation-and-operations/configuration/environment/).

#### Admin user

By default, OpenProject generates an admin user with password `admin` which is required to change after first interactive login.
If you're operating an automated deployment with fresh databases for testing, this default approach might not be desirable.

You can customize the password as well as name, email, and whether a password change is enforced on first login with these variables:

```ruby
openproject.admin_user.password="my-secure-password"
openproject.admin_user.password_reset="false"
openproject.admin_user.name="Firstname Lastname"
openproject.admin_user.mail="admin@example.com"
```

#### Real-time collaboration (Hocuspocus)

OpenProject supports real-time collaboration features through a WebSocket backend called Hocuspocus. To enable Hocuspocus, it is necessary to set the allowed domains for hocuspocus to communicate with:

```yaml
hocuspocus:
  ...

  allowedOpenProjectDomains:
    - my-openproject-domain.com
```

**Important**: The `allowedOpenProjectDomains` can be the top level domain (e.g. my-openproject-domain.com) or subdomain (e.g. openproject.example.com). No wildcards are allowed.

The configuration accepts multiple domains in case of a single websocket server for multiple OpenProject instances.

The domains are passed to the Hocuspocus container as the `ALLOWED_DOMAINS` environment variable (comma-separated). This setting is a security feature that restricts which the Hocuspocus server will be able to connect to.

### TMP volume mounts

OpenProject needs some tmp volumes to be mounted in `/app/tmp` and `/tmp`, if `global.containerSecurityContext.readOnlyRootFilesystem` is set to true.
This is due to the application server storing a non-configurable PID file and some temporary caches or files being put there.

This setting is true by default (to be precise, it follows its configured value or falls back to `develop !=true`)

To explicity disable this, use `openproject.useTmpVolumes=false`. This will fail if `readOnlyRootFilesystem=true`.

These volumes do not contain any critical information and can be excluded from backups using the labels/annotations values.

### ReadWriteMany volumes

By default and when using filesystem-based attachments, OpenProject requires the Kubernetes cluster to support `ReadWriteMany` (rwx) volumes. This is due to the fact that multiple container instances need access to write to the attachment storage.

To avoid using ReadWriteMany, you will need to configure an S3 compatible object storage instead which is shown in the [advanced configuration guide](https://www.openproject.org/docs/installation-and-operations/configuration/#attachments-storage).

```
persistence:
  enabled: false

s3:
  enabled: true
  accessKeyId:
  # host:
  # port:
```

### Updating the configuration

The OpenProject configuration can be changed through environment variables.
You can use `helm upgrade` to set individual values.

For instance:

```shell
helm upgrade --reuse-values --namespace openproject my-openproject --set environment.OPENPROJECT_IMPRESSUM__LINK=https://www.openproject.org/legal/imprint/ --set environment.OPENPROJECT_APP__TITLE='My OpenProject'
```

Find out more about the [configuration through environment variables](https://www.openproject.org/docs/installation-and-operations/configuration/environment/) section.

## Uninstalling the Chart

To uninstall the release with the name my-openproject do the following:

```shell
helm uninstall --namespace openproject my-openproject
```

> **Note**: This will not remove the persistent volumes created while installing.
> The easiest way to ensure all PVCs are deleted as well is to delete the openproject namespace
> (`kubectl delete namespace openproject`). If you installed OpenProject into the default
> namespace, you can delete the volumes manually one by one.

## Troubleshooting

### Web deployment stuck in `CrashLoopBackoff`

Describing the pod may yield an error like the following:

```
65s)  kubelet            Error: failed to start container "openproject": Error response from daemon: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error setting cgroup config for procHooks process: failed to write "400000": write /sys/fs/cgroup/cpu,cpuacct/kubepods/burstable/pod990fa25e-dbf0-4fb7-9b31-9d7106473813/openproject/cpu.cfs_quota_us: invalid argument: unknown
```

This can happen when using **minikube**. By default, it initialises the cluster with 2 CPUs only.

Either increase the cluster's resources to have at least 4 CPUs or install the OpenProject helm chart with a reduced CPU limit by adding the following option to the install command:

```shell
--set resources.limits.cpu=2
```

## Development

To install or update from this directory run the following command.

```bash
bin/install-dev
```

This will install the chart with `--set develop=true` which is recommended
on local clusters such as **minikube** or **kind**.

This will also set `OPENPROJECT_HTTPS` to false so no TLS certificate is required
to access it.

You can set other options just like when installing via `--set`
(e.g. `bin/install-dev --set persistence.enabled=false`).

### Debugging

Changes to the chart can be debugged using the following.

```bash
bin/debug
```

This will try to render the templates and show any errors.
You can set values just like when installing via `--set`
(e.g. `bin/debug --set persistence.enabled=false`).

## TLS

Create a TLS certificate, e.g. using [mkcert](https://github.com/FiloSottile/mkcert).

```
mkcert helm-example.openproject-dev.com
```

Create the tls secret in kubernetes.

```
kubectl -n openproject create secret tls openproject-tls \
  --key="helm-example.openproject-dev.com-key.pem" \
  --cert="helm-example.openproject-dev.com.pem"
```

Set the tls secret value during installation or an upgrade by adding the following.

```
--set ingress.tls.enabled=true --set tls.secretName=openproject-tls
```

### Root CA

If you want to add your own root CA for outgoing TLS connection, do the following.

1. Put the certificate into a config map.

```
kubectl -n openproject-dev create configmap ca-pemstore --from-file=/path/to/rootCA.pem
```

To make OpenProject use this CA for outgoing TLS connection, set the following options.

```
  --set egress.tls.rootCA.configMap=ca-pemstore \
  --set egress.tls.rootCA.fileName=rootCA.pem
```

## Secrets

There are various sensitive credentials used by the chart.
While they can be provided directly in the values (e.g. `--set postgresql.auth.password`),
it is recommended to store them in secrets instead.

You can create a new secret like this:

```
kubectl -n openproject create secret generic <name>
```

You can then edit the secret to add the credentials via the following.

```
kubectl -n openproject edit secret <name>
```

The newly created secret will look something like this:

```
apiVersion: v1
kind: Secret
metadata:
  creationTimestamp: "2024-01-10T09:36:09Z"
  name: <name>
  namespace: openproject
  resourceVersion: "1074377"
  uid: ff6538cd-f8cb-418f-8cee-bd1e20d96d24
type: Opaque
```

To add the actual content, you can simply add `stringData:` to the end of it and save it.
Alternatively you can create the secret in one line as well via the `--from-literal` option.

**Secret keys**

The keys which are looked up inside the secret data can be changed from their defaults in the values as well. This is the same in all cases where next to `existingSecret` you can also set `secretKeys`.

In the following sections we give examples for what this may look like using the default keys for the credentials used by OpenProject.

### PostgreSQL

```yaml
stringData:
  postgres-password: postgresPassword
  password: userPassword
```

Here an example how to do the same using the `--from-literal` option.
We won't give these examples for the other sections below but it works just the same.

```bash
kubectl -n openproject create secret generic db-credentials \
  --from-literal=postgres-password=postgresPassword \
  --from-literal=password=userPassword
```

If you have an existing secret where the keys are not `postgres-password` and `password`, you can customize the used keys as mentioned above.

For instance:

```bash
helm upgrade --create-namespace --namespace openproject --install openproject \
  --set postgresql.auth.existingSecret=mysecret \
  --set postgresql.auth.secretKeys.adminPasswordKey=adminpw \
  --set postgresql.auth.secretKeys.userPasswordKey=userpw
```

This can also be customized for the the credentials in the following sections in the same fashion.
You can look up the respective options in the [`values.yaml`](./values.yaml) file.

#### Default passwords

If you provide neither an existing secret nor passwords directly in the `values.yaml` file,
the postgres chart will generate a secret automatically.

This secret will contain both the user and admin passwords.
You can print the base64 encoded passwords as follows.

```
kubectl get secret -n <namespace> openproject-postgresql -o yaml | grep password
```

### OIDC (OpenID Connect)

```yaml
stringData:
  clientId: 7c6cc104-1d07-4a9f-b3fb-017da8577cec
  clientSecret: <your-client-secret>
```

**Sealed secrets**

```bash
kubectl create secret generic openproject-oidc-secret-sealed --from-literal=OPENPROJECT_OPENID__CONNECT_PROVIDERHERE_IDENTIFIER=xxxxx --from-literal=OPENPROJECT_OPENID__CONNECT_PROVIDERHERE_SECRET=xxxxx --dry-run=client -o yaml | kubeseal ...
```

Set `openproject.oidc.extraOidcSealedSecret="openproject-oidc-secret-sealed"` in your values.

### S3

```yaml
stringData:
  accessKeyId: <your-access-key-id>
  secretAccessKey: <your-secret-access-key>
```

### Incoming E-Mails cron job (IMAP)

```yaml
stringData:
  imapUsername: inbox@mailprovider.com
  imapPassword: <your-imap-password>
```

## OpenShift

For OpenProject to work in OpenShift without further adjustments,
you need to use the following pod and container security context.

```
podSecurityContext:
  supplementalGroups: [1000]
  fsGroup: null

containerSecurityContext:
  runAsUser: null
  runAsGroup: null
```

By default OpenProject requests `fsGroup: 1000` in the pod security context, and also `1000` for both `runAsUser` and `runAsGroup` in the container security context.
You have to allow this using a custom SCC (Security Context Constraint) in the cluster. In this case you do not have to adjust the security contexts.
But the easiest way is the use of the security contexts as shown above.

Due to the default restrictions in OpenShift there may also be issues running
PostgreSQL and memcached. Again, you may have to create an SCC to fix this
or adjust the policies in the subcharts accordingly.

Assuming no further options for both, simply disabling the security context values to use the default works as well.

```
postgresql:
  primary:
    containerSecurityContext:
      enabled: false
    podSecurityContext:
      enabled: false

memcached:
  containerSecurityContext:
    enabled: false
  podSecurityContext:
    enabled: false
```

If Openshift routes with TLS termination `edge` are to be used, TLS of the ingress must be deactivated.

```
ingress:
  host: openproject.example.com
  annotations:
    # generate openshift route
    route.openshift.io/termination: "edge"
  # openshift router offers TLS on edge
  tls:
    enabled: false
```
