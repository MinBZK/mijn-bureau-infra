# ClamAV

MijnBureau supplies an installation of [ClamAV](https://clamav.com/). ClamAV® is an open-source antivirus engine for detecting trojans, viruses, malware & other malicious threats.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                           | Description                     |
| ------------------------------ | ------------------------------- |
| `application.clamav.enabled`   | Enable ClamAV                   |
| `application.clamav.namespace` | The Kubernetes namespace name   |
| `antivirus.*`                  | General antivirus settings      |
| `autoscaling.clamav.*`         | Autoscaling settings            |
| `container.clamav.*`           | Container settings to overwrite |
| `pvc.clamav.*`                 | Storage configuration           |
| `resource.clamav.*`            | Resource configuration          |
