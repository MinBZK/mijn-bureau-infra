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
