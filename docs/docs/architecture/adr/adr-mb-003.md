# ADR-MB-003: System Provisioning

## Status

Accepted

## Context

We need to manage the deployment of multiple Kubernetes applications and services across environments in a consistent, automated, and scalable manner.

We evaluated the following tools for the management of our deployments:

- [Helmfile](https://helmfile.readthedocs.io/en/latest/)
- [ArgoCD ApplicationSet](https://argo-cd.readthedocs.io/en/latest/user-guide/application-set/)
- [Kubernetes Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [cdk8s](https://cdk8s.io/)
- [Terraform](https://developer.hashicorp.com/terraform)

## Decision

We will adopt Helmfile as our Kubernetes provisioning system for the initial implementation phase. Multiple infrastructure teams expressed support for the
Helmfile approach. Kubernetes Operators were ruled out because they require cluster admin privileges. cdk8s was rejected as it demands programming knowledge
from system administrators, creating an unnecessary skill barrier. Terraform and ArgoCD ApplicationSets were also ruled out, due to an increase in learning overhead.

This decision represents an incremental approach that allows us to evaluate more sophisticated solutions in the future based on operational experience and evolving
user requirements from administrators.

## Consequences

**Pros:**

- ✅ With Helmfile we can leverage the existing extensive Helm Chart community ecosystem, which reduces development time.
- ✅ The infrastructure will be declaratively managed in version control, ensuring reproducible deployments.
- ✅ Helmfile does not require specific programming knowledge from infrastructure teams.

**Cons:**

- ❌ Helmfile does not have a type system, which increases development time due to typing mistakes.
- ❌ We cannot use software development best practices and abstractions that we would be able to use in for example cdk8s or Kubernetes Operators.
- ❌ Templating can become complex very quickly, increasing development time.
