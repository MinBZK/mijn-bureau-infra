# ClamAV

MijnBureau supplies an installation of [ClamAV](https://clamav.com/). ClamAV® is an open-source antivirus engine for detecting trojans, viruses, malware & other malicious threats.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                              | Description                     |
| --------------------------------- | ------------------------------- |
| `application.clamav.enabled`      | Enable ClamAV                   |
| `application.clamav.namespace`    | The Kubernetes namespace name   |
| `antivirus.*`                     | General antivirus settings      |
| `antivirus.icap.*`                | ICAP server settings            |
| `autoscaling.horizontal.clamav.*` | Autoscaling settings            |
| `container.clamav.*`              | Container settings to overwrite |
| `container.clamav_icap.*`         | ICAP sidecar image settings     |
| `pvc.clamav.*`                    | Storage configuration           |
| `resource.clamav.*`               | Resource configuration          |

- NOTE: ClamAV requires 3-4GB memory when reading in a new database (see [documentation](https://docs.clamav.net/manual/Installing/Docker.html)). The ICAP sidecar embeds its own clamd and virus database and needs roughly the same amount on top.

## Malware scanning for LaSuite apps

When `antivirus.icap.enabled` is true (default), a c-icap sidecar
(`opencloudeu/clamav-icap`, image configurable via `container.clamav_icap.*`)
runs next to clamd and exposes an ICAP (`RFC 3507`) endpoint on port
`antivirus.icap.port` (default 1344), reachable at
`<antivirus.icap.host>.<application.clamav.namespace>.svc.cluster.local`.

LaSuite applications implementing
[django-lasuite malware detection](https://github.com/suitenumerique/django-lasuite/tree/main/src/lasuite/malware_detection)
(Drive, Conversations) are then automatically wired to it with
`MALWARE_DETECTION_BACKEND=lasuite.malware_detection.backends.icap.ICAPBackend`.
Uploads are scanned from the Celery worker; each app also gets two maintenance
CronJobs (`check_analysis_pending` every 5 minutes and
`reschedule_processing_analysis` nightly) so a lost analysis does not leave an
upload stuck in the ANALYZING state.

Set `antivirus.icap.enabled` to `false` to remove the sidecar; the apps then
fall back to no scanning (Drive/Conversations settings revert to the
DummyBackend default). Docs supports the same backend but currently ships
django-lasuite 0.0.27 (no ICAP backend) and therefore keeps the DummyBackend
until the Docs image is upgraded to >= v6.0.0.
