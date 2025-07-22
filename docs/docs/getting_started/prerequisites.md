---
sidebar_position: 2
---

# Prerequisites

## ☸️ Kubernetes Cluster

Minimal Kubernetes cluster requirements: TODO

## 🛠️ Required CLI Tools

You will need to `kubectl`, the [Kubernetes command line tool](https://kubernetes.io/docs/reference/kubectl/).
We use Helmfile to generate all the Kubernetes manifests. To use Helmfile in our setup you will
need to install:

- [Helm](https://helm.sh/docs/intro/install/)
- [helm-secrets](https://github.com/jkroepke/helm-secrets/wiki/Installation)
- [Helmfile](https://helmfile.readthedocs.io/en/latest/#installation)

## 🌐 Domain Configuration

You will need a domain or subdomain you control.
