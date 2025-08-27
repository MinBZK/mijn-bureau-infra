# ADR-MB-010: ingress controller

## Status

Accepted

## Context

Kubernetes supports a variety of ingress controllers, each with different capabilities, configuration options, and operational characteristics. Choosing the appropriate ingress controller depends on the specific requirements of the platform, such as support for advanced routing, performance, observability, and platform compatibility (e.g., OpenShift).

## Decision

We will start with two ingress controllers:

1. NGINX Ingress Controller: A widely adopted, flexible, and community-supported ingress controller suitable for general Kubernetes use cases.
2. HAProxy-based OpenShift Ingress Controller: The default ingress controller for OpenShift clusters, tightly integrated with OpenShift features and lifecycle management.

These two options allow us to cover both standard Kubernetes and OpenShift-based environments. Additional ingress controllers may be added in the future if new use cases or platform requirements emerge.

## Consequences

- The platform will support both Kubernetes-native and OpenShift-native ingress options from the start.
- Teams must ensure configuration compatibility across both ingress controllers when building reusable ingress manifests.
- If additional requirements arise (e.g., mTLS termination, WAF integration, API gateway capabilities), we may need to introduce other ingress controllers like Traefik, Istio Gateway, or Envoy.
