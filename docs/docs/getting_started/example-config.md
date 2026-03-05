---
sidebar_position: 4
---

# Example Configuration

MijnBureau is highly flexible, allowing for various setups. Below are examples to help you configure MijnBureau for your specific use case.

## Resource Usage of MijnBureau and Applications

Sizing requirements for MijnBureau often depend on the number of users.

### General Resource Configuration

Set the size of your installation using the `resourcesPreset` setting:

```yaml
global:
  # Allowed values: "nano", "micro", "small", "medium", "large", "xlarge", "2xlarge"
  resourcesPreset: "small"
```

### Application-Specific Resource Configuration

Override the general resource settings for specific applications:

```yaml
resource:
  keycloak:
    requests:
      memory: "64Mi"
      cpu: "250m"
    limits:
      memory: "128Mi"
      cpu: "500m"
```

## External Identity Providers

Organizations often use external identity providers. To integrate them with MijnBureau:

1. Create a `client` for each application in the identity provider.
2. Configure MijnBureau with the identity provider's URLs.

### Example Configuration

```yaml
authentication:
  oidc:
    issuer: "https://id.example.com/realms/mijnbureau"
    authorization_endpoint: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/auth"
    token_endpoint: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/token"
    introspection_endpoint: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/token/introspect"
    userinfo_endpoint: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/userinfo"
    end_session_endpoint: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/logout"
    jwks_uri: "https://id.example.com/realms/mijnbureau/protocol/openid-connect/certs"

  client:
    grist:
      client_id: "grist"
      client_secret: secret
    synapse:
      client_id: "synapse"
      client_secret: secret
```

### Customizing Claims

If the default claims differ, update them to match your identity provider's token structure:

```yaml
authentication:
  oidc:
    claims:
      username: preferred_username
      display_name: name
      given_name: given_name
      family_name: family_name
      email: email
      email_verified: email_verified
```

### Using Keycloak

To use Keycloak, MijnBureau's internal identity provider:

```yaml
application:
  keycloak:
    enabled: true

secret: # Store these securely in an encrypted file
  keycloak:
    adminUser: admin
    adminPassword: mypassword

global:
  domain: "mijnbureau.internal"
  hostname:
    keycloak: "id"

authentication:
  oidc:
    issuer: "https://id.mijnbureau.internal/realms/mijnbureau"
    authorization_endpoint: "https://id.mijnbureau.internal/realms/mijnbureau/protocol/openid-connect/auth"
    token_endpoint: "https://id.mijnbureau.internal/realms/mijnbureau/protocol/openid-connect/token"
    introspection_endpoint: "https://id.mijnbureau.internal/realms/mijnbureau/protocol/openid-connect/token/introspect"
    userinfo_endpoint: "https://id.mijnbureau.internal/realms/mijnbureau/protocol/openid-connect/userinfo"
    end_session_endpoint: "https://id.mijnbureau.internal/realms/mijnbureau/protocol/openid-connect/logout"
    jwks_uri: "https://id.mijnbureau.internal/realms/mijnbureau/protocol/openid-connect/certs"
```

### Demo Users

For demo environments, you can configure demo users:

```yaml
user:
  - email: johndoe@example.com
    username: johndoe
    firstname: John
    lastname: Doe
    password: myStrongPassword123
  - email: janedoe@example.com
    username: janedoe
    firstname: Jane
    lastname: Doe
    password: myStrongPassword123
```

## Enabling/Disabling Applications

Enable or disable specific applications:

```yaml
application:
  grist:
    enabled: false
  ollama:
    enabled: false
  keycloak:
    enabled: true
  chat:
    enabled: true
```

### Namespace Configuration

By default, MijnBureau uses your **current Kubernetes context namespace** for all applications. This means if you're already logged into a namespace, helmfile will automatically deploy to that namespace without any additional configuration.

To check your current context and namespace:

```bash
kubectl config get-contexts
```

The current context is marked with `*` and the namespace column shows where deployments will go.

To set your context namespace:

```bash
kubectl config set-context --current --namespace=my-namespace
```

You can also override namespaces per application for more fine-grained control:

```yaml
application:
  keycloak:
    enabled: true
    namespace: my-keycloak-namespace
  element:
    enabled: true
    namespace: my-chat-namespace
```

**Tip:** For production or shared clusters, consider using per-app namespaces for better isolation between applications and their dependencies.

Enable namespace creation if permissions allow:

```bash
export MIJNBUREAU_CREATE_NAMESPACES=true
```

## Cluster Configuration

Adjust cluster-specific settings:

```yaml
cluster:
  networking:
    domain: cluster.local
    podSubnet:
      - "10.244.0.0/16"
    serviceSubnet:
      - "10.96.0.0/12"

  # Routing mode — selects how ingress traffic reaches the applications.
  # Allowed values: ingress (default), gateway-api, none
  routingMode: ingress

  ingress: # used when routingMode = ingress
    type: nginx # nginx or haproxy-openshift
    className: ~
    annotations: ~
```

### Gateway API Configuration

If your cluster runs a [Gateway API](https://gateway-api.sigs.k8s.io/) controller, you can use `gateway-api` as the routing mode instead. MijnBureau will then deploy a shared `Gateway` resource and create `HTTPRoute` objects for all applications rather than `Ingress` objects.

```yaml
cluster:
  routingMode: gateway-api

  gateway:
    # Name of the shared Gateway resource (default: mijnbureau-gateway)
    name: mijnbureau-gateway
    # Namespace for the Gateway resource — defaults to the release namespace
    namespace: ~
    # Must match the installed Gateway API controller (e.g. nginx, cilium, envoy-gateway, istio)
    className: nginx
    # cert-manager ClusterIssuer used to provision TLS certificates
    certManagerClusterIssuer: letsencrypt-prod
    # Which namespaces may attach HTTPRoutes to the Gateway.
    # "All" is required when apps run in per-app namespaces (the default).
    # For shared/production clusters consider "Selector" with an appropriate label.
    allowedRoutesNamespacesFrom: All
    # Annotations applied to the Gateway resource
    annotations: ~
```

## Storage Configuration

Configure PersistentVolumeClaims (PVCs) for storage:

### Default PVC Settings

```yaml
pvc:
  default:
    storageClass: ~
    size: "1Gi"
    accessModes:
      - ReadWriteOnce
```

### Application-Specific PVC Settings

```yaml
pvc:
  ollama:
    storageClass: MyBackedupStorageclass
    size: 15Gi
    accessModes:
      - ReadWriteMany
```

## Security Context

Customize security contexts for containers and pods:

```yaml
security:
  default:
    containerSecurityContext:
      enabled: true
      seLinuxOptions: {}
      allowPrivilegeEscalation: false
      capabilities:
        drop:
          - "ALL"
      privileged: false
      runAsUser: 1001
      runAsGroup: 1001
      readOnlyRootFilesystem: true
      runAsNonRoot: true

    podSecurityContext:
      enabled: true
      fsGroupChangePolicy: Always
      sysctls: []
      supplementalGroups: []
      fsGroup: 1001
```

## External AI LLM

Change the default Ollama model or configure an external AI LLM endpoint:

```yaml
application:
  ollama:
    enabled: true
    model: "llama3.2"
```

```yaml
ai:
  llm:
    model: "gpt-4.1"
    endpoint:
      host: your-custom-endpoint.com
      port: 443
      openApiVersion: "v1"
      isSsl: true
      isInternal: false
    apiKey: yourapikey
```

## TLS Setup

### Ingress mode

Specify TLS settings per application:

```yaml
tls:
  keycloak:
    - hosts:
        - keycloak.mijnbureau.internal
```

Add cert-manager annotations to provision certificates automatically:

```yaml
cluster:
  ingress:
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
```

### Gateway API mode

In Gateway API mode, certificates are provisioned centrally via the `cluster.gateway.certManagerClusterIssuer` setting. No per-application TLS configuration or annotations are needed — the shared `Gateway` resource handles TLS termination for all applications.

:::note
cert-manager requires additional configuration to support Gateway API. See the [cert-manager Gateway API docs](https://cert-manager.io/docs/usage/gateway/) for details.
:::

## Customizing Containers

Override default containers or use a proxy server:

```yaml
container:
  default:
    registry: myproxyserver
    imagePullSecret: myproxyserversecret

  ollama:
    registry: "docker.io"
    repository: "yourcontainer"
    tag: "yourtag"
```

## Customizing Charts

Replace default charts with your own:

```yaml
chart:
  keycloak:
    registry: registry-1.docker.io
    repository: yourrepository
    version: yourversion
    verify: false
    oci: true
    username: ~
    password: ~
```

## Licenses

Provide licenses for enterprise features:

```yaml
license:
  grist:
    key: yourlicencekey
```

## Email Configuration

Configure SMTP settings for transactional emails:

```yaml
smtp:
  from:
    email: you@example.com
    name: "Mijn Bureau"
  host: youremailhostname
  port: 587
  tls:
    enabled: true
    force: true
    requireTransportSecurity: false
  username: yourusername
  password: yourpassword
```
