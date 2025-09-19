---
sidebar_position: 5
---

# Deploy MijnBureau

This guide explains how to deploy MijnBureau to a locally run Kubernetes cluster, allowing you to verify your changes.

---

## KIND: Kubernetes in Docker

We use Kubernetes in Docker (KIND) to test MijnBureau locally. Refer to the [KIND Documentation](https://kind.sigs.k8s.io) for installation instructions.

You will also need a LoadBalancer for kind. We use [Cloud Provider Kind](https://kind.sigs.k8s.io/docs/user/loadbalancer/#installing-cloud-provider-kind)

To install cloud provider kind:

```bash
go install sigs.k8s.io/cloud-provider-kind@latest
```

### Create a KIND Cluster

To create a local Kubernetes cluster using KIND, run:

```bash
./scripts/kind.sh
sudo cloud-provider-kind
```

This will create a kind cluster named mijnbureau and sets up an Nginx ingress and Gateway API.

Once kind is running we can yet use it. We need to route all traffic to a loadbalancer.

To get the ip adress of the loadbalancer execute the following

```bash
kubectl get service ingress-nginx-controller
```

Then add the following into /etc/hosts where loadbalancerip is replaced with the external-ip from the previous command.

```txt
<loadbalancerip> id.kubernetes.local
<loadbalancerip> id-admin.kubernetes.local
<loadbalancerip> grist.kubernetes.local
<loadbalancerip> nextcloud.kubernetes.local
<loadbalancerip> chat.kubernetes.local
<loadbalancerip> matrix.kubernetes.local
<loadbalancerip> <other>.kubernetes.local
```

### Delete the KIND Cluster

When you are done testing, delete the cluster with:

```bash
kind delete cluster --name mijnbureau
```

---

## Deploy MijnBureau

### Set Master Password

Set the master password for deterministic secret generation and allow namespace creation:

```bash
export MIJNBUREAU_MASTER_PASSWORD="your-very-secure-password"
export MIJNBUREAU_CREATE_NAMESPACES=true
```

### Simple example configuration

Often you do not want to deploy everything of MijnBureau when developing. In this example configurations we show how you can test a small number of applications.

```yaml
global:
  resourcesPreset: "micro"

application:
  grist:
    enabled: true
    namespace: grist

  keycloak:
    enabled: true
    namespace: keycloak

  ollama:
    enabled: false

  chat:
    enabled: false

  nextcloud:
    enabled: false
```

We assume you use a self signed certificate with the domain kubernetes.local which is default for the ./scripts/kind.sh. If you changed the domain, you need to change more settings.

### Verify Kubernetes Connection

Ensure you are connected to the correct Kubernetes cluster. Check the current context with:

```bash
kubectl config current-context
```

### Install MijnBureau

To deploy MijnBureau to your Kubernetes cluster, execute:

```bash
helmfile -e <environment> apply
```

Replace `<environment>` with the desired environment, such as `demo` or `production`. If you do not specify the `-e <environment>` option, MijnBureau will use the default environment.

### Inspect Installation

If you want to inspect the installation without deploying, use:

```bash
helmfile -e <environment> template
```

---

## Additional Helmfile Commands

Helmfile provides many additional commands for managing your deployment. Refer to the [Helmfile CLI Reference](https://helmfile.readthedocs.io/en/latest/#cli-reference) for more details.
