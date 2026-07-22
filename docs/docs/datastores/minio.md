---
sidebar_position: 5
---

# Object Stores

Object stores are designed to store and retrieve large amounts of unstructured data, such as files, images, and backups. They are highly scalable and offer features like versioning, replication, and lifecycle management.

## Managed vs. Self-Hosted Object Stores

- **Managed Services**: Cloud providers offer fully managed object storage solutions. These services handle infrastructure, scaling, and maintenance.
- **Self-Hosted Solutions**: Tools like Garage or Minio allow you to deploy and manage your own object store, providing greater control and data sovereignty.

## Deploying MinIO in Kubernetes

MinIO is a high-performance, self-hosted object storage solution compatible with the S3 API. It can be deployed in Kubernetes using Helm charts, which simplify deployment and provide scalability and security options.

To deploy MinIO, use an HelmChart.

## Integrating ObjectStore with MijnBureau

ObjectStores can be integrated into MijnBureau for storing application data, backups, or other unstructured data. The default configuration for each application is located in `helmfile/environments/default/objectstore.yaml.gotmpl`.

### Example: Configuring MinIO for MijnBureau

To configure ObjectStore, add the following to `helmfile/environments/production/mijnbureau.yaml.gotmpl`:

```yaml
objectstore:
  grist:
    bucket: "grist"
    username: "admin"
    endpoint: "yourhostname"
    port: 9000
    useSSL: false
    isInternal: true
    rootPassword: yourpassword
```

### Securing MinIO Credentials

Storing credentials directly in configuration files is not recommended. Use a secrets file to manage credentials securely:

1. Add the credentials to a secrets file:

   ```yaml
   objectstore:
     grist:
       username: "admin"
       rootPassword: yourpassword
   ```

   Save this in `helmfile/environments/production/example.secrets.yaml`.

2. Remove the `username` (comparable to `accessKey`) and `rootPassword` (comparable to `secretKey`) fields from `mijnbureau.yaml.gotmpl`.

3. Encrypt the secrets file using SOPS:

   ```bash
   sops -e -i helmfile/environments/production/example.secrets.yaml
   ```

4. Ensure your CI/CD system is configured to decrypt the secrets during deployment.

By following these steps, you can securely integrate MinIO into MijnBureau while maintaining a clean and organized configuration structure.
