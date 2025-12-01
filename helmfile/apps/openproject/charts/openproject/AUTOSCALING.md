# OpenProject HPA Autoscaling

This guide explains how to set up autoscaling for OpenProject using Kubernetes Horizontal Pod Autoscaler (HPA).

## Overview

HPA provides automatic scaling for Kubernetes workloads, allowing OpenProject to scale based on:

- **CPU/Memory metrics** (built-in, no external dependencies)
- **Custom metrics from Prometheus** (requires Prometheus Adapter)

HPA is a native Kubernetes feature that automatically scales deployments based on observed metrics.

## Prerequisites

### 1. Kubernetes Metrics Server

The metrics server must be installed for resource-based scaling (CPU/Memory):

```bash
# Check if metrics server is installed
kubectl get deployment metrics-server -n kube-system

# If not installed, install it using Helm:
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# For development environments (minikube, kind, etc.):
helm install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args="{--cert-dir=/tmp,--secure-port=4443,--kubelet-preferred-address-types=InternalIP\,ExternalIP\,Hostname,--kubelet-use-node-status-port,--metric-resolution=15s,--kubelet-insecure-tls}"

# For production environments (remove --kubelet-insecure-tls):
# helm install metrics-server metrics-server/metrics-server \
#   --namespace kube-system \
#   --set args="{--cert-dir=/tmp,--secure-port=4443,--kubelet-preferred-address-types=InternalIP\,ExternalIP\,Hostname,--kubelet-use-node-status-port,--metric-resolution=15s}"

# Verify installation
kubectl top nodes
kubectl top pods -n kube-system
```

### 2. Prometheus (For Custom Metrics)

**Option A: Prometheus Operator (Recommended for ServiceMonitor support)**

The Prometheus Operator provides the ServiceMonitor CRD required for automatic service discovery:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus Operator with full stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

**Option B: Minimal Prometheus (Basic metrics collection)**

```bash
# Install lightweight Prometheus (no ServiceMonitor support)
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --create-namespace \
  --set alertmanager.enabled=false \
  --set prometheus-node-exporter.enabled=false \
  --set prometheus-pushgateway.enabled=false \
  --set kube-state-metrics.enabled=false \
  --set server.persistentVolume.enabled=false
```

**Option C: Install Prometheus Operator CRDs only**

If you need ServiceMonitor support but want minimal installation:

```bash
# Install only the CRDs
kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.85.0/bundle.yaml

# Then install minimal Prometheus
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --create-namespace \
  --set alertmanager.enabled=false \
  --set prometheus-node-exporter.enabled=false \
  --set prometheus-pushgateway.enabled=false \
  --set kube-state-metrics.enabled=false \
  --set server.persistentVolume.enabled=false
```

**Verify Prometheus Operator installation:**

```bash
# Check if ServiceMonitor CRD is available
kubectl get crd servicemonitors.monitoring.coreos.com

# Check if Prometheus Operator is running
kubectl get pods -n monitoring | grep prometheus-operator
```

### 3. Prometheus Adapter (Required for Custom Metrics)

The Prometheus Adapter makes Prometheus metrics available to HPA via the Custom Metrics API.

```bash
# Install Prometheus Adapter
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade prometheus-adapter prometheus-community/prometheus-adapter \
  --namespace monitoring \
  --values examples/prometheus-adapter-values.yaml
```

**Verify Prometheus Adapter installation:**

```bash
# Check if custom metrics API is available
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1

# Check for our specific metric (after OpenProject is running with metrics enabled)
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/openproject/pods/*/puma_request_backlog_avg_1min"
```

## Configuration

### Basic CPU/Memory Scaling

Enable basic autoscaling using CPU and memory metrics:

```yaml
# values.yaml
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  # targetMemoryUtilizationPercentage: 80  # Uncomment to enable memory scaling

# Enable custom metrics collection
metrics:
  enabled: true
  serviceMonitor:
    enabled: true # Requires Prometheus Operator CRDs
```

### Advanced Custom Metrics Scaling

Scale based on OpenProject-specific metrics using the `puma_request_backlog` gauge:

```yaml
# values.yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 20

  # Resource-based scaling (fallback)
  targetCPUUtilizationPercentage: 70

  # Custom metrics scaling
  customMetrics:
    # Scale when request backlog exceeds 2 requests over 1 minute average
    - type: Pods
      pods:
        metric:
          name: puma_request_backlog_avg_1min
        target:
          type: AverageValue
          averageValue: "2" # Scale up when backlog > 2 requests

  # Advanced scaling behavior
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300 # Wait 5 minutes before scaling down
      policies:
        - type: Pods
          value: 1
          periodSeconds: 60
        - type: Percent
          value: 10
          periodSeconds: 60
      selectPolicy: Min
    scaleUp:
      stabilizationWindowSeconds: 60 # Wait 1 minute before scaling up
      policies:
        - type: Pods
          value: 2
          periodSeconds: 60
        - type: Percent
          value: 50
          periodSeconds: 60
      selectPolicy: Max

# Enable metrics collection
metrics:
  enabled: true
  path: "/metrics"
  port: 9394
  serviceMonitor:
    enabled: true # For Prometheus Operator
```

### Multiple Custom Metrics Example

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 20

  customMetrics:
    # Scale based on request backlog
    - type: Pods
      pods:
        metric:
          name: puma_request_backlog_avg_1min
        target:
          type: AverageValue
          averageValue: "2" # Scale when avg backlog across pods > 2 requests

    # Scale based on response time (if available)
    - type: Pods
      pods:
        metric:
          name: puma_busy_threads_avg_1min
        target:
          type: AverageValue
          averageValue: "2" # Scale when avg busy threads across pods > 2
```

## Load Testing to Trigger Autoscaling

To test the HPA scaling behavior, you need to generate enough load to increase the `puma_request_backlog` above the threshold (2 requests).

For a simple test without installing additional tools:

```yaml
# loadtest-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: openproject-loadtest
  namespace: openproject
spec:
  parallelism: 30
  completions: 500
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: curl
          image: curlimages/curl:latest
          command: ["/bin/sh"]
          args:
            - -c
            - |
              for i in $(seq 1 10000); do
                curl -s http://openproject:8080/health_checks/all
              done
```

```bash
kubectl apply -f loadtest-job.yaml
```

### Monitoring During Load Testing

While running load tests, monitor the scaling behavior:

```bash
# Watch HPA status in real-time
kubectl get hpa openproject-web-hpa -n openproject -w

# Watch pod scaling
kubectl get pods -n openproject -w

# Check current puma backlog
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/openproject/pods/*/puma_request_backlog_avg_1min" | jq '.items[].value'

# Monitor Prometheus metrics
curl -s "http://localhost:9091/api/v1/query?query=puma_request_backlog" | jq '.data.result[].value[1]'
```

## Monitoring and Troubleshooting

### Check Metrics Availability

```bash
# Test metrics endpoint directly
kubectl port-forward -n openproject deployment/openproject-web 9394:9394
curl http://localhost:9394/metrics | grep puma_request_backlog

# Check if Prometheus is scraping metrics
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
# Visit http://localhost:9090/targets
```

### Test Custom Metrics API

```bash
# Check if custom metrics are available
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq

# Check specific metric
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/openproject/pods/*/puma_request_backlog_avg_1min" | jq
```

### Common Prometheus Queries

Test your queries directly in Prometheus UI:

```promql
# Current puma request backlog
puma_request_backlog

# Average backlog over 1 minute
avg_over_time(puma_request_backlog[1m])

# Average request backlog across all pods
avg(avg_over_time(puma_request_backlog[1m]))
```

### Debugging Steps

1. **HPA shows "Unknown" for custom metrics:**

   ```bash
   # Check Prometheus Adapter logs
   kubectl logs -n monitoring deployment/prometheus-adapter

   # Verify metric is available in Prometheus
   kubectl port-forward -n monitoring svc/prometheus-server 9090:80
   # Query: puma_request_backlog

   # Check custom metrics API
   kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1
   ```

2. **Metrics not available:**

   ```bash
   # Verify OpenProject metrics are enabled
   kubectl get service -n openproject -o yaml | grep metrics

   # Check ServiceMonitor (if using Prometheus Operator)
   kubectl get servicemonitor -n openproject

   # Test metrics endpoint
   kubectl exec -n openproject deployment/openproject-web -- curl localhost:9394/metrics
   ```

3. **ServiceMonitor CRD not found error:**

   ```bash
   # Check if Prometheus Operator CRDs are installed
   kubectl get crd servicemonitors.monitoring.coreos.com

   # If not found, install Prometheus Operator CRDs (see above)
   ```

4. **HPA not scaling:**

   ```bash
   # Check HPA status and conditions
   kubectl describe hpa -n openproject

   # Check deployment replica count
   kubectl get deployment -n openproject

   # Monitor HPA in real-time
   kubectl get hpa -n openproject -w
   ```

5. **Prometheus connection issues:**
   ```bash
   # Test connectivity from adapter to Prometheus
   kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
     curl http://prometheus-server.monitoring.svc.cluster.local/api/v1/query?query=up
   ```

## Production Considerations

1. **Resource Limits**: Set appropriate CPU/memory requests and limits on HPA target deployment
2. **Monitoring**: Monitor HPA scaling events and metric accuracy
3. **Testing**: Load test autoscaling behavior before production deployment
4. **Alerting**: Set up alerts for scaling events and metric availability
5. **Security**: Use authentication for Prometheus in production environments
6. **Networking**: Ensure Prometheus Adapter can reach Prometheus across namespaces
7. **Backup Strategy**: Always configure resource-based scaling as a fallback

## Troubleshooting Guide

| Issue                        | Cause                             | Solution                                            |
| ---------------------------- | --------------------------------- | --------------------------------------------------- |
| ServiceMonitor CRD not found | Prometheus Operator not installed | Install Prometheus Operator CRDs or full stack      |
| HPA shows "Unknown" metrics  | Custom metrics API not available  | Check Prometheus Adapter installation and logs      |
| No scaling activity          | Metrics below/above thresholds    | Check metric values and adjust thresholds           |
| Metrics not found            | Metric name mismatch              | Verify metric name in Prometheus and adapter config |
| Scaling too aggressive       | Short stabilization window        | Increase `stabilizationWindowSeconds`               |
| Can't reach Prometheus       | Network/DNS issues                | Verify Prometheus URL and network connectivity      |
| Authentication errors        | Wrong credentials                 | Check Prometheus authentication configuration       |
| HPA created but not active   | Target deployment not found       | Verify deployment name matches HPA target           |

For more information, see the [official Kubernetes HPA documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) and [Prometheus Adapter documentation](https://github.com/kubernetes-sigs/prometheus-adapter).
