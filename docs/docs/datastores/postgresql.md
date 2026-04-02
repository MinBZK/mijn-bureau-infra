---
sidebar_position: 3
---

# PostgreSQL

PostgreSQL, or Postgres, is a powerful open-source relational database management system (RDBMS). It is known for its robustness, extensibility, and compliance with SQL standards. PostgreSQL supports advanced data types, full-text search, and is widely used for applications requiring complex queries and high reliability.

## Deploying PostgreSQL in Kubernetes with CloudNativePG

[CloudNativePG](https://cloudnative-pg.io/) is an open-source operator for managing PostgreSQL clusters in Kubernetes. It simplifies the deployment, scaling, and management of PostgreSQL databases in a cloud-native environment.

### Key Features of CloudNativePG

- Automated failover and high availability.
- Backup and restore capabilities.
- Rolling updates for PostgreSQL clusters.
- Integration with Kubernetes-native tools.

### Example: Deploying a PostgreSQL Cluster

The following Kubernetes manifest demonstrates how to deploy a PostgreSQL cluster using CloudNativePG:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-example
spec:
  instances: 3
  storage:
    size: 1Gi
```

### Steps to Deploy

1. **Install the CloudNativePG operator**:  
   Refer to the [official documentation](https://cloudnative-pg.io/documentation/1.27/installation_upgrade/) for installation instructions.

2. **Apply the PostgreSQL cluster manifest**:  
   Save the example manifest above, customize it as needed, and apply it:

   ```bash
   kubectl apply -f cloudnativepg-postgresql.yaml
   ```

   The example above demonstrates a basic PostgreSQL cluster. CloudNativePG also supports additional resources, such as backups.

## PostgreSQL Vendors

Several vendors provide managed PostgreSQL services, simplifying deployment and maintenance by handling the underlying infrastructure. Research vendors in your region or consult your organization to identify commonly used providers.

## Using CloudNativePG with MijnBureau Apps

MijnBureau apps can optionally use CloudNativePG `Cluster` resources for their PostgreSQL databases instead of the default Bitnami PostgreSQL subchart. The CNPG operator must be installed by a cluster administrator first.

To switch an app (e.g., Grist) to CNPG, set the `provider` and `host` in your environment values (e.g., `helmfile/environments/production/mijnbureau.yaml.gotmpl`):

```yaml
database:
  grist:
    provider: cnpg
    host: grist-cnpg-cluster-rw
```

The `host` must be set to `<app>-cnpg-cluster-rw` — CNPG automatically creates a `<cluster-name>-rw` service that points to the primary instance.

## Integrating PostgreSQL with MijnBureau

Once you have one or more databases available, you can configure MijnBureau to use an external database. The default configuration for each application is located in `helmfile/environments/default/database.yaml.gotmpl`.

### Example: Configuring the Grist Database

To configure the Grist database, add the following to `helmfile/environments/production/mijnbureau.yaml.gotmpl`:

```yaml
database:
  grist:
    type: postgresql
    host: yourdatabasehost
    name: databasename
    user: databaseuser
    port: 5432
    isInternal: true # Controls network policy
    password: your user password
```

### Securing Database Passwords

Storing passwords directly in configuration files is not recommended, as they might be accidentally checked in and exposed. Instead, move the password to a separate secrets file.

1. Add the following to `helmfile/environments/production/example.secrets.yaml`:

   ```yaml
   database:
     grist:
       password: your user password
   ```

2. Remove the `password` field from `mijnbureau.yaml.gotmpl`.

3. Encrypt the secrets file using SOPS:

   ```bash
   sops -e -i helmfile/environments/production/example.secrets.yaml
   ```

4. Ensure your CI/CD system is configured to decrypt the secrets during deployment.

By following these steps, you can securely manage database credentials while maintaining a clean configuration structure.
