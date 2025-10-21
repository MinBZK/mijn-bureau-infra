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

Specify the Kubernetes namespace for each application:

```yaml
application:
  keycloak:
    enabled: true
    namespace: mykeycloaknamespace
  chat:
    enabled: true
    namespace: mychatnamespace
```

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

  ingress:
    type: nginx
    className: ~
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

Specify TLS settings for ingress:

```yaml
tls:
  keycloak:
    - hosts:
        - keycloak.mijnbureau.internal
```

Add cert-manager annotations if needed:

```yaml
cluster:
  ingress:
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
```

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
