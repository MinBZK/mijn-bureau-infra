---
sidebar_position: 2
---

# Prerequisites

MijnBureau has minimal prerequisites, requiring only a Kubernetes cluster and some essential tools.

---

## ☸️ Kubernetes Cluster

### Minimum Requirements

- A [CNCF certified](https://www.cncf.io/training/certification/software-conformance/) Kubernetes or [Haven](https://haven.commonground.nl/) compliant Kubernetes.
- AMD64 platform.
- A LoadBalancer.
- An ingress controller: Nginx or HAProxy (OpenShift).

> Note: Currently, MijnBureau supports only the Nginx and HAProxy ingress controllers. Additional controllers can be added if needed.

### Kubernetes Resources

MijnBureau simplifies resource setup with a global size parameter that adjusts resource usage for all components. Below is the expected resource usage based on the size parameter only. For precise calculations, use the `./script/predicted_resources.py` script.

#### Resource Usage by Size

| Size        | Environment | CPU Requested | CPU Limits  | Memory Requested | Memory Limits |
| ----------- | ----------- | ------------- | ----------- | ---------------- | ------------- |
| **nano**    | Demo        | 4.7 cores     | 7.2 cores   | 7.5 GiB          | 12.3 GiB      |
|             | Production  | 2.4 cores     | 3.8 cores   | 4.6 GiB          | 7.9 GiB       |
| **micro**   | Demo        | 11.1 cores    | 16.9 cores  | 13.0 GiB         | 20.6 GiB      |
|             | Production  | 5.4 cores     | 8.3 cores   | 7.1 GiB          | 11.7 GiB      |
| **small**   | Demo        | 21.9 cores    | 33.0 cores  | 24.0 GiB         | 37.1 GiB      |
|             | Production  | 10.4 cores    | 15.7 cores  | 12.2 GiB         | 19.5 GiB      |
| **medium**  | Demo        | 21.9 cores    | 33.0 cores  | 46.0 GiB         | 70.1 GiB      |
|             | Production  | 10.4 cores    | 15.8 cores  | 22.5 GiB         | 34.8 GiB      |
| **large**   | Demo        | 43.4 cores    | 65.2 cores  | 90.1 GiB         | 136.1 GiB     |
|             | Production  | 20.4 cores    | 30.8 cores  | 43.0 GiB         | 65.5 GiB      |
| **xlarge**  | Demo        | 43.4 cores    | 129.7 cores | 134.1 GiB        | 268.3 GiB     |
|             | Production  | 20.4 cores    | 60.7 cores  | 63.5 GiB         | 127.0 GiB     |
| **2xlarge** | Demo        | 43.4 cores    | 258.8 cores | 134.1 GiB        | 532.5 GiB     |
|             | Production  | 20.4 cores    | 120.8 cores | 63.5 GiB         | 250.0 GiB     |

nano and micro size will give issues with some of the workloads. You can resolve this by defining resources for these workloads in the resources.yaml

## 🛠️ Tools

To install MijnBureau on Kubernetes, you need the following tools:

- **Helmfile**: Used to generate Kubernetes manifests. [Installation Guide](https://helmfile.readthedocs.io/en/latest/#installation)
- **Helm**: [Installation Guide](https://helm.sh/docs/intro/install/)

### Secrets Management

If you plan to store secrets like credentials, we recommend using an encryption tool or secret manager. This documentation uses SOPS, but you can choose another tool based on your organization’s needs:

- **SOPS**: [Documentation](https://getsops.io/)
- **AGE**: [Documentation](https://github.com/FiloSottile/age)

---

## 🌐 Domain Configuration

MijnBureau is primarily a browser-based suite. You will need a domain or subdomain you control to make the tool accessible to users.
