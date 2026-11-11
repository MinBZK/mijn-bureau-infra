# Meet

MijnBureau supplies an installation of [Meet](https://github.com/suitenumerique/meet). It is a video conferencing solutions that uses livekit.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                                        | Description                                                  |
| ------------------------------------------- | ------------------------------------------------------------ |
| `global.domain`                             | The domain name of your MijnBureau instance                  |
| `global.hostname.meet`                      | The name of the subdomain for the meet client                |
| `application.meet.enabled`                  | Enable meet for your MijnBureau implementation               |
| `application.meet.namespace`                | The Kubernetes namespace name                                |
| `application.meet.celeryBackend.enabled`    | Enable the backend Celery worker                             |
| `application.meet.agents.enabled`           | Enable the LiveKit metadata agent                            |
| `application.meet.agents.subtitles.enabled` | Enable the LiveKit subtitles agent (off by default)          |
| `application.meet.summary.enabled`          | Enable AI summarization; transcription follows `ai.whisperx` |
| `authorization.meet.enabled`                | Enable meet for your MijnBureau implementation               |
| `tls.meet.*`                                | The TLS settings for meet                                    |
| `livekit.meet.*`                            | Livekit connection                                           |
| `pvc.meet.*`                                | storage requirements                                         |
| `resources.meet.*`                          | Resources for meet                                           |
| `autoscaling.horizontal.meet.*`             | Autoscaling for meet.                                        |
| `container.meet.*`                          | Container selection                                          |
| `container.meet_agents.*`                   | Container selection for the LiveKit agents                   |
| `container.meet_summary.*`                  | Container selection for transcription workers                |
| `objectstore.meet.*`                        | MinIO bucket and credentials for Meet media                  |
| `global.hostname.meet-minio`                | Public hostname for the Meet MinIO endpoint                  |
| `pvc.meet.minio.*`                          | Storage for the bundled MinIO instance                       |
| `secret.meet.*`                             | Superuser credentials and summary API tokens                 |

## More information

Meet is a video conferencing frontend for LiveKit. You can use the bundled LiveKit deployment within MijnBureau or connect to an external, hosted LiveKit instance. Please note that running video conferencing reliably on Kubernetes can be challenging due to networking and scaling requirements.

Currently, Firefox browser support is not fully stable. A known fix exists, but it has not yet been implemented in this deployment.

AI summarization is enabled by default when the shared LLM is configured. The other AI features are opt-in:

- Summarization (`celery-summarize`) starts automatically when `ai.llm.endpoint.host` and `ai.llm.model` are set. The worker also needs S3-compatible storage for result files.
- Transcription (`celery-transcribe`) starts automatically when `ai.whisperx.baseUrl` is configured.
- LiveKit agents require `application.meet.agents.enabled: true`, LiveKit credentials and S3-compatible object storage. The metadata agent (`agent-metadata`) runs by default once agents are enabled.
- The subtitles agent (`agent-subtitles`) is opt-in: set `application.meet.agents.subtitles.enabled: true` and configure an STT provider. Extra variables can be supplied through `application.meet.agents.envVars`.
- Extra summary environment variables can be supplied through `application.meet.summary.envVars`. S3-compatible object storage is configured through `objectstore.meet` when available.

Set `application.meet.summary.enabled: false` to disable the summarization workers even when an LLM is configured.

## Object storage

In the `demo` environment, Meet deploys a dedicated MinIO instance (`meet-minio`). The chart configures the Meet backend with the internal S3 endpoint (`http://meet-minio:9000`) and exposes the public MinIO endpoint at `https://meet-minio.<global.domain>` for presigned download URLs. The bucket is defined by `objectstore.meet.bucket`, and credentials come from `objectstore.meet.username` and `objectstore.meet.rootPassword`.

Add a DNS record for `meet-minio.<global.domain>` pointing to the gateway or ingress address. Set `pvc.meet.minio.size` to change the MinIO volume size.

## Recording

Meet uses LiveKit Egress to record rooms. Recording is enabled automatically
when `application.livekit.enabled` and `application.livekit.egress.enabled` are
both `true`. Egress uploads recordings to the Meet MinIO bucket, and MinIO sends
object-created events to Meet's storage webhook so the recording is marked as
ready and its owners are notified.

Recordings require working outbound email (SMTP) for the download
notifications. Without SMTP, owners can still find the download link in the
Django admin under Core > Recordings.

## AI, transcription and subtitles

Meet reads shared AI settings from `helmfile/environments/default/ai.yaml.gotmpl`:

| Name            | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| `ai.llm.*`      | LLM endpoint used by the summarize worker                    |
| `ai.whisperx.*` | WhisperX-compatible batch transcription endpoint             |
| `ai.stt.*`      | Real-time speech-to-text provider used by the LiveKit agents |

Store API keys in your environment's untracked secrets file, not in `ai.yaml.gotmpl`.

### WhisperX transcription

`celery-transcribe` sends audio to an OpenAI-compatible WhisperX endpoint:

```yaml
ai:
  whisperx:
    baseUrl: https://whisperx.example.com/v1
    apiKey: <secret>
    asrModel: large-v3
    defaultLanguage: nl
```

If `defaultLanguage` is empty, Meet uses `global.defaultLocale`.

### Real-time speech-to-text

The `agent-subtitles` LiveKit agent supports Deepgram, Kyutai and Voxtral vLLM:

```yaml
ai:
  stt:
    provider: deepgram
    deepgram:
      apiKey: <secret>
      model: nova-3
      language: multi
```

Set `provider: kyutai` with `kyutai.baseUrl` and optional `kyutai.apiKey`, or
`provider: voxtral-vllm` with `voxtral.baseUrl`, `voxtral.apiKey` and
`voxtral.model`.

### OpenRouter model suggestions

OpenRouter provides an OpenAI-compatible endpoint for the LLM used by
`celery-summarize`. It does **not** provide WhisperX or real-time STT; use a
separate WhisperX service and an STT provider for those.

```yaml
ai:
  llm:
    model: google/gemini-2.5-flash
    endpoint:
      host: openrouter.ai/api
      path: v1
      isSsl: true
      isInternal: false
    apiKey: <secret>
```

Suggested OpenRouter models for meeting summaries:

| Model                          | Notes                                            |
| ------------------------------ | ------------------------------------------------ |
| `google/gemini-2.5-flash`      | Fast, low cost and a large context window        |
| `openai/gpt-5-mini`            | Balanced quality and cost for longer transcripts |
| `anthropic/claude-haiku-5.5`   | Fast model with good writing quality             |
| `deepseek/deepseek-v4.1-flash` | Very low cost with a long context window         |
| `deepseek/deepseek-v3.2`       | Low-cost alternative for shorter meetings        |

Model availability and pricing change frequently; check
[openrouter.ai/models](https://openrouter.ai/models) before choosing one.

For more details or to request additional features, please refer to the official [Meet documentation](https://github.com/suitenumerique/meet).
