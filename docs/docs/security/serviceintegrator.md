---
sidebar_position: 4
---

# Service Integrator

A Service Integrator is the organization responsible for making MijnBureau available to users and ensuring its security. This includes securely configuring both Kubernetes and MijnBureau—a critical responsibility and a key value proposition for service integrators.

The security of MijnBureau is closely tied to the underlying Kubernetes cluster. Service integrators must apply Kubernetes security best practices. Below are several practices that are native to Kubernetes:

1. **Enable "deny all" network policies** to restrict traffic by default.
2. **Enforce Pod and Container Security Contexts** to ensure least privilege.
3. **Deploy across multiple regions** to improve resilience.

These recommendations are not ranked; assess which are most relevant for your workload.

## Policies

Implement automated security controls using policies. [Kyverno](https://kyverno.io/) is a popular choice for Kubernetes policy management.

## Secret Rotation

Regularly rotate secrets to minimize risk. The [External Secrets Operator](https://external-secrets.io/latest/) can automate secret management.

## Container Sandboxes

Use container runtime sandboxes for isolation. Popular options include [gVisor](https://gvisor.dev/) and [Kata Containers](https://katacontainers.io/).

## Disaster Recovery

Establish backup and restore systems, ideally outside Kubernetes. Test restore procedures regularly. Tools like [Velero](https://velero.io/) are useful for disaster recovery.

## CVE Scanning

Scan container images for vulnerabilities (CVEs) on a regular basis. [Trivy](https://trivy.dev/latest/) is a widely used tool for this purpose.

## Dedicated Cluster

Consider running MijnBureau on a dedicated Kubernetes cluster to reduce risks from other workloads.

## Removing Unused Images

Remove unused or insecure container images from your cluster. [Eraser](https://www.cncf.io/projects/eraser/) can help automate this process.

## Security Monitoring

Install monitoring tools such as [Falco](https://falco.org/) on Kubernetes nodes to detect and respond to security events. Stream audit logs to a central system and set up alerting rules.

## Container Network Interface Provider

Select a Container Network Interface (CNI) provider with robust security options and configure it according to best practices.

## Container Storage Interface

Choose a Container Storage Interface (CSI) provider that supports encryption at rest. Ensure your storage solution meets security requirements and is properly configured.

## Control Plane Node

Never run workloads on the Kubernetes control plane node.

## Observability

Implement observability systems to track metrics and logs. MijnBureau supports Prometheus for metrics and can integrate with the Prometheus Operator. Logs are sent to container STDOUT and can be collected using Kubernetes tools. Store logs and metrics for analysis.

## AppArmor

Enable [AppArmor](https://kubernetes.io/docs/tutorials/security/apparmor/) profiles for workloads to enhance container security.

## Pod Security Standards

Enable [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) in all relevant namespaces. MijnBureau recommends using `Restricted` mode and enforcing it for strict security.

## DDoS Protection

Implement DDoS protection for services exposed by your Kubernetes cluster.

## CIS Benchmarks

Use [kube-bench](https://github.com/aquasecurity/kube-bench) to scan your Kubernetes configuration and adhere to the latest CIS Kubernetes benchmarks.

## Confidential Containers

Consider [Confidential Containers](https://confidentialcontainers.org/) to secure application memory and prevent unauthorized access.

## Limit Ranges

Set up [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/) to prevent containers from consuming excessive resources.
