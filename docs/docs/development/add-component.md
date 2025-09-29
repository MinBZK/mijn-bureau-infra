---
sidebar_position: 3
---

# New Component

This guide explains how to add a new component to MijnBureau. It outlines the architectural decisions and rules that must be followed to ensure consistency and flexibility across the suite.

---

## Template

To add a new component, start by using the provided template. Copy the template from the [GitHub repository](https://github.com/MinBZK/mijn-bureau-infra/tree/main/template) and implement the relevant options for your component.

### Template Location

Copy the template to the following directory:

```bash
./helmfile/apps/<yourapp>/charts/<yourapp>
```

---

## Charts

External charts not maintained by Bitnami are not allowed. If you need to use an external chart, port the necessary parts into the provided template.

---

## Flexibility and Consistency

MijnBureau aims to maintain flexibility and consistency. When creating a new component, adhere to the following rules and implement the specified variables to align with the suite's standards.

### Key Requirements

1. **Flexible Resource Usage**:
   - Use variables from `./helmfile/environments/default/resource.yaml.gotmpl`.
2. **Flexible Helm Charts**:
   - Use variables from `./helmfile/environments/default/chart.yaml.gotmpl`.
3. **Flexible Containers**:
   - Use variables from `./helmfile/environments/default/container.yaml.gotmpl`.
4. **Configurable PVCs**:
   - Use `./helmfile/environments/default/pvc.yaml.gotmpl`.
5. **Container and Pod Security**:
   - Implement security settings from `./helmfile/environments/default/security.yaml.gotmpl`.
6. **Component Enable/Disable**:
   - Add switches in `./helmfile/environments/default/application.yaml.gotmpl`.
7. **OIDC Variables**:
   - Use `./helmfile/environments/default/authentication.yaml.gotmpl`.
8. **Autoscaling Features**:
   - Implement autoscaling using `./helmfile/environments/default/autoscaling.yaml.gotmpl`.
9. **Demo Environment Support**:
   - Add switches to deploy required datastores in the demo environment.
10. **Configurable Datastores**:
    - Use `cache.yaml.gotmpl`, `database.yaml.gotmpl`, and `objectstore.yaml.gotmpl`.
11. **Global Variables**:
    - Use `./helmfile/environments/default/global.yaml.gotmpl` where logical.
12. **AI Variables**:
    - Use `./helmfile/environments/default/ai.yaml.gotmpl` where logical.
13. **Cluster Variables**:
    - Use `./helmfile/environments/default/cluster.yaml.gotmpl` where logical.

---

## OpenID Connect (OIDC)

All new user-facing tools must support OpenID Connect (OIDC) for authentication. Backchannel logout support is preferred.

---

## SCIM

While MijnBureau does not currently support SCIM, it is planned for future updates.

---

## Network Policies

MijnBureau operates in Kubernetes environments with a default deny network policy. Explicit network policies must be created for new components.

### Example: Default Deny Network Policy

Below is an example of a default deny network policy for Kubernetes:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```
