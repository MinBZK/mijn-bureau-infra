---
sidebar_position: 5
---

# Deploy KIND

This guide walks you through deploying MijnBureau to a local Kubernetes cluster for development and testing. We use [KIND](https://kind.sigs.k8s.io/) (Kubernetes IN Docker) as the primary example, but you can also use Minikube or Docker Desktop’s Kubernetes if you prefer.

---

## 1. Prerequisites

- [KIND](https://kind.sigs.k8s.io/docs/user/quick-start/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [Go](https://go.dev/doc/install) (for installing cloud-provider-kind)
- [Helm](https://helm.sh/docs/intro/install/)
- [Helmfile](https://helmfile.readthedocs.io/en/latest/#installation)
- [mkcerts](https://github.com/FiloSottile/mkcert)

---

## 2. Setting Up KIND with LoadBalancer

MijnBureau requires a LoadBalancer for features like video conferencing. KIND clusters do not provide this by default, so we use [cloud-provider-kind](https://kind.sigs.k8s.io/docs/user/loadbalancer/#installing-cloud-provider-kind).

### Install cloud-provider-kind

```bash
go install sigs.k8s.io/cloud-provider-kind@latest
```

> **Note:** Linux users may need to supply the full path to `go` and perform: `sudo mv ~/go/bin/cloud-provider-kind /usr/local/go/bin/`.

### Create the KIND Cluster

Run the following script to create a KIND cluster named `mijnbureau` and set up NGINX ingress, Gateway API, and self-signed certificates:

```bash
./scripts/kind.sh
sudo cloud-provider-kind
```

> **Note:** If you do not need video conferencing, you can skip cloud-provider-kind.

### Delete the KIND Cluster

When finished, clean up with:

```bash
kind delete cluster --name mijnbureau
```

---

## 3. Configure MijnBureau for Local Development

You may not want to deploy all MijnBureau components during development. Here’s a minimal example configuration for local testing:

```yaml
global:
  domain: "127.0.0.1.sslip.io"
  resourcesPreset: "small"
  tls:
    selfSigned: true

secret:
  grist:
    adminEmail: johndoe@example.com

application:
  grist:
    enabled: true
    namespace: grist
  keycloak:
    enabled: true
    namespace: keycloak
  ollama:
    enabled: false
    namespace: ollama
  chat:
    enabled: false
    namespace: chat
  nextcloud:
    enabled: false
    namespace: nextcloud
  collabora:
    enabled: false
    namespace: collabora
```

You can copy this setup into file: helmfile/environments/demo/mijnbureau.yaml.gotmpl

---

## 4. Set Required Environment Variables

Set the master password and allow namespace creation:

```bash
export MIJNBUREAU_MASTER_PASSWORD="your-very-secure-password"
export MIJNBUREAU_CREATE_NAMESPACES=true
```

---

## 5. Verify Kubernetes Context

Ensure you are connected to the correct cluster:

```bash
kubectl config current-context
```

---

## 6. Deploy MijnBureau

Apply your configuration with Helmfile:

```bash
helmfile init
helmfile -e <environment> apply
```

Replace `<environment>` with your target environment (e.g., `demo`, `production`). If omitted, the default environment is used.

When the deployment is succesfull you will be able to connect to the tools. These URLS should work depending on which applications you enabled.

- [id](https://id.127.0.0.1.sslip.io)
- [id-admin](https://chat.127.0.0.1.sslip.io)
- [matrix](https://matrix.127.0.0.1.sslip.io)
- [grist](https://grist.127.0.0.1.sslip.io)
- [collabora](https://collabora.127.0.0.1.sslip.io)
- [nextcloud](https://nextcloud.127.0.0.1.sslip.io)

---

## 7. Inspect the Installation

To render manifests without deploying:

```bash
helmfile -e <environment> template
```

---

## 8. More Helmfile Commands

Helmfile offers many commands for managing deployments. See the [Helmfile CLI Reference](https://helmfile.readthedocs.io/en/latest/#cli-reference) for details.

---

**Tip:** For troubleshooting, check logs with `kubectl logs` and inspect resources with `kubectl get all -A`.
