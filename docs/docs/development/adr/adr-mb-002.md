# ADR-MB-002: Kubernetes as the deployment platform

## Status

Accepted

## Context

We need a reliable, scalable, and flexible deployment platform to run and manage our containerized applications across different environments. Many options are available, like kubernetes, VMs, Docker swarm

## Decision

We will use Kubernetes as our standard deployment platform for all environments. We will assume a [Haven](https://haven.commonground.nl/) compliant cluster.

## Consequences

**Pros:**

- ✅ Enables a consistent deployment model across environments
- ✅ Improves scalability, observability, and resilience of applications
- ✅ Leverages ecosystem tools for CI/CD, monitoring, logging, and security

**Cons:**

- ❌ Increases complexity and learning curve for development teams
- ❌ Requires ongoing cluster management and resource tuning
- ❌ Potential overkill for small/simple apps unless managed Kubernetes (e.g., GKE, AKS, EKS) is used
