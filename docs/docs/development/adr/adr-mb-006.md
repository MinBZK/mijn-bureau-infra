# ADR-MB-006: Datastores

## Status

Accepted

## Context

Many applications in the `MijnBureau` application suite have multiple dependencies on datastores,
including relational database management systems, in-memory caching layers and object storage services.
Examples are PostgreSQL, Redis and MinIO.

Organizations typically maintain existing data infratructure for their datastores.
Moreover, regulatory compliance frameworks such as the GDPR often mandate specific data residency,
encryption and audit requirements that influence datastore selection and configuration.

## Decision

We will provide datastores only for our demo environment. We will not provide datastores for our
production environment, but instead insist that users provide their own datastores.

## Consequences

**Pros:**

- ✅ Demo environments can be deployed quickly with all dependencies included.
- ✅ Organizations can leverage their existing datastores, managed services and operational expertise.
- ✅ Organizations maintain full control over their data storage, allowing them to meet specific
  compliance requirements.
- ✅ Organizations can integrate datastores into their existing backup and recovery procedures.

**Cons:**

- ❌ Production deployments require additional setup and configuration of external datastores before
  mijn bureau can be installed.
- ❌ Organizations probably will need comprehensive documentation for configuring external datastores.
- ❌ We cannot easily test all possible datastore configurations.
- ❌ Organizations must manage datastore versions, security patches and compatability with `MijnBureau`
  updates.
