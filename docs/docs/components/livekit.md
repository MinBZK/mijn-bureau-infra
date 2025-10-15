# Livekit

MijnBureau supplies an installation of [livekit](https://livekit.io/). Livekit is an open-source video conferencing backend that enables video conferencing through the WebRTC standard. Running video conferencing requires in-dept knowledge of your network. You can also use a [hosted livekit](https://livekit.io/pricing) solution if that better suites your needs.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                   | Description                                                                                |
| -------------------------------------- | ------------------------------------------------------------------------------------------ |
| `global.domain`                        | The domain name of your MijnBureau instance                                                |
| `global.hostname.livekit`              | The subdomain name                                                                         |
| `application.livekit.enabled`          | Enable Livekit                                                                             |
| `application.livekit.namespace`        | The Kubernetes namespace name                                                              |
| `application.livekit.loadBalancerIP`   | External IP of the loadbalancer                                                            |
| `application.livekit.port_range_start` | Loadbalancer UDP port range start                                                          |
| `application.livekit.port_range_end`   | Loadbalancer UDP port range end                                                            |
| `application.livekit.keys.*`           | Keys that are allowed to connect to livekit, you often want a key per external application |
| `tls.livekit.*`                        | The TLS settings                                                                           |
| `autoscaling.horizontal.livekit.*`     | Scaling settings                                                                           |
| `container.livekit.*`                  | Container settings to overwrite                                                            |
| `pvc.livekit.*`                        | Storage configuration                                                                      |
| `resources.livekit.*`                  | Resource configuration                                                                     |
| `cache.livekit.*`                      | Cache configuration                                                                        |

## Setup

Deploying Livekit on Kubernetes requires special consideration for media traffic routing via RTC. Livekit needs a load balancer with a range of UDP ports assigned for media streams. However, some Kubernetes loadbalancers do not natively support allocate port ranges to a single service since some ports are already assigned to other customers. Contact your administrator to see if they can help assign a range of ports or get a dedicated loadbalancer for MijnBureau.

If your load balancer supports port ranges, configure them as follows:

```yaml
application:
  livekit:
    portRangeStart: 30001 # Start of UDP port range for media traffic
    portRangeEnd: 30009 # End of UDP port range
```

Often Kubernetes loadbalancers assign the NodePorts randomly and do not listen to the requested ports. You may need to manually set the NodePort values for the Livekit service loadbalancer. If you edit it manually the loadbalancer will listen if the port is available.

## STUN setup

Livekit uses the STUN protocol to determine its external IP address for the loadbalancer, which is essential for peer connectivity. In some cases, automatic discovery may fail so we disabled it by default. To ensure reliability, you can explicitly set the external IP and use the provided cronjob and job to keep it updated based on the service status.

## TURN Setup

Enabling a TURN server enhances connectivity for users behind restrictive firewalls or NAT. TURN requires TLS termination, which can be handled either by your load balancer or directly within the Livekit pod.

You have two options for TLS termination:

### Option 1: Load Balancer TLS Termination

To terminate TLS at the load balancer, update the Livekit configuration to indicate that TLS is handled externally. Although official support is pending, you can enable this feature as follows:

1. Open `helmfile/apps/livekit/values.yaml.gotmpl`.
2. Locate the `livekit.config.turn` section.
3. Set `external_tls` to `true`.

This configuration tells Livekit to expect TLS termination at the load balancer.

### Option 2: TLS Certificate in Namespace

If you prefer the Livekit pod to handle TLS termination, you must provide a TLS secret containing your certificate and key for the TURN server domain:

```yaml
turn-{{ .Values.global.hostname.livekit }}.{{ .Values.global.domain }}
```

Steps:

1. Obtain a TLS certificate and key for the TURN server domain and set DNS to the turn loadbalancer IP
2. Create a Kubernetes TLS secret in the Livekit namespace:

```bash
kubectl create secret tls turn-tls-livekit-secret \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key \
  -n livekit-namespace
```

3. Reference the secret in your Livekit configuration:

```yaml
application:
  livekit:
    turnTLSecretName: turn-tls-livekit-secret
```

This setup allows Livekit to terminate TLS for TURN traffic using the provided certificate.
