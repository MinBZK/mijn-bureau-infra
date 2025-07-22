# ADR-MB-007: manifest tests

## Status

Accepted

## Context

As our Kubernetes infrastructure grows, we need to ensure that all deployed manifests adhere to our policies and security standards.

Without automated policy validation, we risk:

- Security vulnerabilities in production
- Non-compliant resources that are hard to manage
- Inconsistent labeling and metadata
- Resource sprawl and cost issues

## Decision

We will use **Conftest** for Kubernetes manifest policy testing, with policies written in **Rego** (Open Policy Agent language).

### Alternatives Considered

| Tool           | Pros                                                                                                          | Cons                                                                                   | Decision        |
| -------------- | ------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | --------------- |
| **Conftest**   | - Simple CLI integration<br/>- Rego policy language<br/>- Flexible input formats<br/>- Good CI/CD integration | - Smaller community<br/>- Fewer pre-built policies                                     | ✅ **Selected** |
| **Kyverno**    | - Kubernetes-native<br/>- YAML-based policies<br/>- Larger community<br/>- More examples available            | - More complex setup<br/>- Kubernetes-specific only<br/>- More verbose policy syntax   | ❌ Not selected |
| **Gatekeeper** | - Kubernetes admission controller<br/>- Runtime enforcement<br/>- OPA integration                             | - Complex setup<br/>- Requires cluster deployment<br/>- Overhead for simple validation | ❌ Not selected |
| **Polaris**    | - Good dashboard<br/>- Pre-built policies<br/>- Easy to start                                                 | - Limited customization<br/>- No custom policy language                                | ❌ Not selected |

## Consequences

**Pros:**

- ✅ **Developer Experience**: Simple CLI tool that integrates well with existing workflows
- ✅ **Flexibility**: Rego allows complex policy logic and custom validation rules
- ✅ **CI/CD Integration**: Easy to integrate into GitHub Actions and other CI systems
- ✅ **Multi-format Support**: Works with YAML, JSON, and other structured data formats
- ✅ **Offline Testing**: Can validate manifests without requiring a Kubernetes cluster
- ✅ **Extensibility**: Easy to add new policies as requirements evolve

**Cons:**

- ❌ **Learning Curve**: Team needs to learn Rego syntax for policy development
- ❌ **Community Size**: Smaller community compared to Kyverno, fewer examples available
- ❌ **Documentation**: Less comprehensive documentation and tutorials
- ❌ **Runtime Enforcement**: No built-in runtime policy enforcement (validation only)
