# Livekit

MijnBureau supplies an installation of [livekit](https://livekit.io/). Livekit is an open-source video conferencing backend that enables video conferencing through the WebRTC standard. Running video conferencing requires in-dept knowledge of your network. You can also use a [hosted livekit](https://livekit.io/pricing) solution if that better suites your needs.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                     | Description                                                                                                     |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `global.domain`                          | The domain name of your MijnBureau instance                                                                     |
| `global.hostname.livekit`                | The subdomain name                                                                                              |
| `application.livekit.enabled`            | Enable Livekit                                                                                                  |
| `application.livekit.namespace`          | The Kubernetes namespace name                                                                                   |
| `application.livekit.loadBalancerIP`     | External IP of the loadbalancer                                                                                 |
| `application.livekit.port_range_start`   | Loadbalancer UDP port range start                                                                               |
| `application.livekit.port_range_end`     | Loadbalancer UDP port range end                                                                                 |
| `application.livekit.keys.*`             | Keys that are allowed to connect to livekit, you often want a key per external application                      |
| `livekit.meet.apiKey`                    | Optional key name Meet uses; when combined with `livekit.meet.apiSecret` it is added to the LiveKit server keys |
| `livekit.meet.apiSecret`                 | Optional secret for the Meet key; overrides the generated key secret on the LiveKit server                      |
| `application.livekit.egress.enabled`     | Deploy LiveKit Egress for recording and streaming                                                               |
| `tls.livekit.*`                          | The TLS settings                                                                                                |
| `autoscaling.horizontal.livekit.*`       | Scaling settings                                                                                                |
| `autoscaling.horizontal.livekitEgress.*` | Scaling settings for egress                                                                                     |
| `container.livekit.*`                    | Container settings to overwrite                                                                                 |
| `container.livekit_egress.*`             | Container settings for egress                                                                                   |
| `pvc.livekit.*`                          | Storage configuration                                                                                           |
| `resources.livekit.*`                    | Resource configuration                                                                                          |
| `cache.livekit.*`                        | Cache configuration                                                                                             |

## Egress

LiveKit Egress is deployed together with the LiveKit server when
`application.livekit.egress.enabled` is `true`. It connects to the local
LiveKit server and the local Valkey instance and uploads recordings to the
Meet MinIO bucket configured in `objectstore.meet`. Meet enables its recording
feature automatically when egress is enabled.

Egress records one room per replica. Increase `egress.replicaCount`
(or enable `autoscaling.horizontal.livekitEgress`) if multiple rooms should be
recorded at the same time. Room composite recordings need roughly 2-4 CPUs;
tune `egress.config.cpu_cost.*` in the chart when a worker runs on smaller nodes,
otherwise egress refuses to schedule the recording.

Egress needs temporary disk space while a recording is finalized. The built-in
resource presets cap `ephemeral-storage` at 2Gi; set `resource.livekit.egress`
with an `ephemeral-storage` limit large enough for your longest recording.

Chrome sandboxing is disabled by default because it requires the `clone` and
`unshare` syscalls. Set `egress.config.enable_chrome_sandbox: true` in the chart
only when the cluster allows those syscalls.

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
