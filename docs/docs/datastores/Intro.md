---
sidebar_position: 2
---

# Introduction to Datastores

Data is a critical component of MijnBureau, as users will create and share significant amounts of information. This guide explains how datastores are managed in both the Demo and Production environments.

---

## Demo Environment

In the Demo environment, MijnBureau deploys all required datastores, including:

- **PostgreSQL Databases**
- **Redis Caches**
- **MinIO Object Stores**

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

1. **Datastores**: Set up and configure external datastores (e.g., PostgreSQL, Redis, MinIO).
2. **Persistent Volume Claims (PVCs)**: MijnBureau uses PVCs to store important data. Ensure these are backed up regularly.

> **Recommendation**: Use a tool like [Velero](https://velero.io/) to manage PVC backups effectively.
