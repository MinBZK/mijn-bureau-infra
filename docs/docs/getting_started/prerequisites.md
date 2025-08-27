---
sidebar_position: 2
---

# Prerequisites

## ☸️ Kubernetes Cluster

Minimal Kubernetes cluster requirements:

- A CNCF certified kubernetes software conformance
- Resources
  - cpu: 10 cores
  - memory: 128GB
  - diskspace: 200GB
- AMD64 platform
- A Loadbalancer
- A ingress controller (Nginx or HAProxy-openshift)
- A SMTP server (email)

## 🛠️ Required CLI Tools

You will need to `kubectl`, the [Kubernetes command line tool](https://kubernetes.io/docs/reference/kubectl/).

We use Helmfile to generate all the Kubernetes manifests. To use Helmfile in our setup you will
need to install:

- [Helm](https://helm.sh/docs/intro/install/)
- [helm-secrets](https://github.com/jkroepke/helm-secrets/wiki/Installation)
- [Helmfile](https://helmfile.readthedocs.io/en/latest/#installation)

## 🌐 Domain Configuration

You will need a domain or subdomain you control.
