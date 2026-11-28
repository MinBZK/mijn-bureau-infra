---
sidebar_position: 10
---

# Introduction to Datastores

Data is a critical component of MijnBureau, as users will create and share significant amounts of information. This guide explains how datastores are managed in both the Demo and Production environments.

---

## Demo Environment

In the Demo environment, MijnBureau deploys all required datastores, including:

- **PostgreSQL Databases**
- **Valkey Caches**
- **SeaweedFS Object Stores**
- **OpenSearch Search Index**

> **Note**: The Demo environment is intended for testing and evaluation purposes, but if done correctly can be configured for production usage.

---

## Production Environment

In the Production environment, MijnBureau does not deploy datastores. Instead, you must configure MijnBureau to connect to externally managed datastores. This approach allows organizations to use specialized tools for:

- **Backup and Restore**
- **Disaster Recovery**

### Why Exclude Datastores in Production?

Every organization handles data differently. While some may use Kubernetes-managed datastores, others might prefer externally managed solutions. By excluding datastores, MijnBureau provides flexibility to integrate with your existing infrastructure.

### Preparing for Production

Before deploying a production environment, ensure the following:

1. **Datastores**: Set up and configure external datastores (e.g., PostgreSQL, Valkey, SeaweedFS, OpenSearch).
2. **Persistent Volume Claims (PVCs)**: MijnBureau uses PVCs to store important data. Ensure these are backed up regularly.

Each datastore needs its own protection: CloudNativePG archives WAL and base
backups to object storage, while the object store, Valkey and OpenSearch rely on
bucket copies or volume snapshots. See [Backups](../backup-restore.md) for the mechanism
per datastore and a restore checklist, and [Backups with Velero](../backup-restore.md)
for namespace and PVC backups.
