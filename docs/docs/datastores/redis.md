---
sidebar_position: 4
---

# Redis

Redis is an open-source, in-memory data structure store that serves as a database, cache, and message broker. It is widely used for its high performance, simplicity, and versatility, making it ideal for applications requiring low-latency data access.

## Deploying Redis in Kubernetes

Redis can be deployed in Kubernetes using various Helm charts. These charts provide secure and scalable deployment options.

## Redis Vendors

Several vendors offer managed Redis services, simplifying deployment and maintenance by handling the underlying infrastructure. Check with your organization to determine the preferred Redis provider.

## Integrating Redis with MijnBureau

Redis can be integrated into MijnBureau for purposes such as:

- Caching
- Session management
- Message brokering

The default configuration for each application is located in `helmfile/environments/default/cache.yaml.gotmpl`.

### Example: Configuring Redis for MijnBureau

To configure Redis for MijnBureau, add the following to `helmfile/environments/production/mijnbureau.yaml.gotmpl`:

```yaml
cache:
  nextcloud:
    host: yourhostname
    port: 6379
    isInternal: true #manages networkpolicies to go outside or inside the cluster
    password:
      {
        {
          derivePassword 1 "long" (env "MIJNBUREAU_MASTER_PASSWORD" | default "mijn-bureau") "redis" "password" | sha1sum | quote,
        },
      }
```

### Securing Redis Passwords

Storing passwords directly in configuration files is not recommended. Instead, use a separate secrets file. Follow these steps to secure Redis credentials:

1. Add the password to a secrets file:

   ```yaml
   cache:
     nextcloud:
       password: your redis password
   ```

   Save this in `helmfile/environments/production/example.secrets.yaml`.

2. Remove the `password` field from `mijnbureau.yaml.gotmpl`.

3. Encrypt the secrets file using SOPS:

   ```bash
   sops -e -i helmfile/environments/production/example.secrets.yaml
   ```

4. Ensure your CI/CD system is configured to decrypt the secrets during deployment.

By following these steps, you can securely manage Redis credentials while maintaining a clean and organized configuration structure.
