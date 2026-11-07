---
sidebar_position: 4
---

# Valkey

Valkey is the Linux Foundation fork of Redis. It is an open-source, in-memory data structure store used as a database, cache and message broker, and it remains protocol- and client-compatible with Redis.

The bundled demo environment deploys Valkey with the official [valkey-io/valkey-helm](https://github.com/valkey-io/valkey-helm) chart and the `valkey/valkey` image.

## Deploying Valkey in Kubernetes

Each enabled app gets a standalone Valkey instance in its own namespace:

- release and Service name: `<app>-valkey`
- port: `6379`
- authentication: ACL `default` user
- persistence: AOF enabled, PVC sized from `pvc.<app>.valkey`
- metrics: optional `oliver006/redis_exporter` sidecar

## Valkey Vendors

Several vendors offer managed Redis/Valkey services. Check with your organization to determine the preferred provider. MijnBureau connects to any Redis-compatible endpoint.

## Integrating Valkey with MijnBureau

Valkey can be integrated into MijnBureau for:

- Caching
- Session management
- Message brokering

The default configuration for each application is located in `helmfile/environments/default/cache.yaml.gotmpl`.

### Example: Configuring Valkey for MijnBureau

To use an external Valkey/Redis endpoint, add the following to `helmfile/environments/production/mijnbureau.yaml.gotmpl`:

```yaml
cache:
  nextcloud:
    host: yourhostname
    port: 6379
    isInternal: true # manages network policies for internal/external access
    password: your-valkey-password
```

### Securing Valkey Passwords

Storing passwords directly in configuration files is not recommended. Instead, use a separate secrets file:

1. Add the password to a secrets file:

   ```yaml
   cache:
     nextcloud:
       password: your valkey password
   ```

   Save this in `helmfile/environments/production/example.secrets.yaml`.

2. Remove the `password` field from `mijnbureau.yaml.gotmpl`.

3. Encrypt the secrets file using SOPS:

   ```bash
   sops -e -i helmfile/environments/production/example.secrets.yaml
   ```

4. Ensure your CI/CD system is configured to decrypt the secrets during deployment.

By following these steps, you can securely manage Valkey credentials while maintaining a clean and organized configuration structure.
