---
sidebar_position: 10
---

# GitOps

To implement GitOps in your infrastructure, you can use tools such as [Flux](https://fluxcd.io/) or [ArgoCD](https://argo-cd.readthedocs.io/en/stable/). This documentation focuses on configuring ArgoCD, as Flux does not natively support Helmfile at this time.

## ArgoCD

ArgoCD supports Helm, Kustomize, and Jsonnet out of the box. Since this project uses Helmfile, you need to add Helmfile support to ArgoCD using a ConfigManagementPlugin. For more details, refer to the [official ArgoCD documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/config-management-plugins/).

### Step 1: Add Helmfile Plugin to ArgoCD

Create a `ConfigManagementPlugin` in a ConfigMap within the namespace where ArgoCD is deployed:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: helmfile-plugin-config
data:
  plugin.yaml: |
    apiVersion: argoproj.io/v1alpha1
    kind: ConfigManagementPlugin
    metadata:
      name: helmfile
    spec:
      version: v1.1
      init:
        command: [sh, -c]
        args: | 
          helmfile init
      generate:
        command: [sh, -c]
        args:
          - |
            export MIJNBUREAU_MASTER_PASSWORD=$ARGOCD_ENV_MIJNBUREAU_MASTER_PASSWORD

            if [ -z "$ARGOCD_ENV_ENVIRONMENT" ]; then
              helmfile -e demo template
            else
              helmfile -e $ARGOCD_ENV_ENVIRONMENT template
            fi
      discover:
        fileName: "./helmfile.yaml.gotmpl"
```

### Step 2: Enable the Plugin and Provide Helmfile Binary

Next, configure the ArgoCD repo server to use the Helmfile plugin and ensure the Helmfile binary is available. This example uses the ArgoCD Operator, but you can apply the same approach to a standard ArgoCD installation.

```yaml
apiVersion: argoproj.io/v1beta1
kind: ArgoCD
metadata:
  name: argo
spec:
  ...
  repo:
    volumes:
    - name: helmfile-tools
      emptyDir: {}
    - configMap:
        name: helmfile-plugin-config
      name: helmfile-plugin-config
    initContainers:
    - name: download-helmfile
      image: ghcr.io/helmfile/helmfile:v1.1.7
      command: [sh, -c]
      args:
        - cp /usr/local/bin/helmfile /helmfile-tools/helmfile && cp /usr/local/bin/helm /helmfile-tools/helm && cp -r /helm/.local/share/helm/plugins/  /helmfile-tools/plugins/
      volumeMounts:
      - mountPath: /helmfile-tools
        name: helmfile-tools
    sidecarContainers:
      - name: cmp
        command: [/var/run/argocd/argocd-cmp-server]
        image: ghcr.io/helmfile/helmfile:v1.1.7
        volumeMounts:
          - mountPath: /var/run/argocd
            name: var-files
          - mountPath: /home/argocd/cmp-server/plugins
            name: plugins
          - mountPath: /home/argocd/cmp-server/config/plugin.yaml
            subPath: plugin.yaml
            name: helmfile-plugin-config
    volumeMounts:
    - mountPath: /usr/local/bin/helmfile
      name: helmfile-tools
      subPath: helmfile
    - mountPath: /usr/local/sbin/helm
      name: helmfile-tools
      subPath: helm
    - mountPath: /.local/share/helm/plugins/
      name: helmfile-tools
      subPath: plugins
  ...
```

### Step 3: Deploy Your Application

With ArgoCD configured, you can now deploy your application using the following manifest:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mijn-bureau
spec:
  project: default
  source:
    repoURL: https://github.com/MinBZK/mijn-bureau-deploy-demo.git
    path: .
    targetRevision: HEAD
    plugin:
      env:
        - name: ENVIRONMENT
          value: demo
        - name: MIJNBUREAU_MASTER_PASSWORD
          value: <todo:usesecretsforthis>
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

This completes the ArgoCD configuration for deploying Helmfile-based applications.
