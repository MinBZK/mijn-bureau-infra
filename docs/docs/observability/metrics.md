# Metrics

MijnBureau provides built-in metrics powered by Prometheus. You can enable metrics collection by setting the appropriate options in your MijnBureau configuration file.

To enable metrics, add the following to your configuration:

```yaml
metric:
  enabled: true
```

If you have the [Prometheus Operator](https://prometheus-operator.dev/) installed on your kubernetes cluster, you can automatically collect metrics by enabling additional monitoring options:

```yaml
serviceMonitor:
  enabled: true
prometheusRule:
  enabled: true
podMonitor:
  enabled: true
```

For more details about these monitors, refer to the Prometheus Operator documentation.

## Prometheus namespace

Per-app `NetworkPolicy` ingress rules grant scrape access only to pods in the namespace hosting your Prometheus installation. The default is `monitoring`; override this if you installed `kube-prometheus-stack` (or any other Prometheus) elsewhere:

```yaml
metric:
  enabled: true
  namespace: observability # defaults to "monitoring"
```

Setting this updates every app's `NetworkPolicy` ingress rules and the Nextcloud exporter's dedicated policy in one place.
