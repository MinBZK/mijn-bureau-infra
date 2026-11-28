---
sidebar_position: 165
---

# AI services

_Where this fits: this page covers deployment and configuration. How to use it: [AI assistant](../user-guide/conversations.md) and [Transcription](../user-guide/dictaphone.md)._

MijnBureau uses AI for four different jobs: chat and writing assistance, OCR of uploaded
documents, batch transcription of recordings, and real-time transcription during
meetings. Each job has its own configuration block under `ai.*` in
`helmfile/environments/default/ai.yaml.gotmpl`, so you can mix providers per job: a
European LLM for chat, Mistral OCR for documents and a self-hosted speech model for
meetings.

:::note No provider endorsement
Providers named on this page (Mistral, VLAM.ai, OpenRouter, OpenAI, Deepgram, Kyutai,
Ollama, self-hosted vLLM) are examples that show the supported configuration shapes.
MijnBureau does not promote, recommend or support one provider over another. Every
organisation is free to choose the provider that fits its requirements and remains
responsible for that provider's contract terms, data processing agreement and data
residency.
:::

AI features follow the shared language-model configuration. With the default deployment,
`application.ollama.enabled` is `true`, so Conversations and Messages use the bundled
`llama3.2:1b` model even when `ai.llm` is empty. Docs and Bureaublad require an explicit
`ai.llm.model` and endpoint. Meet summaries and transcription require `ai.llm.*` and
`ai.whisperx.*` respectively. Without any configured model those features stay hidden.

## What uses AI

| Feature                      | Configuration                     | Used for                                                  |
| ---------------------------- | --------------------------------- | --------------------------------------------------------- |
| Conversations (AI Assistant) | `ai.llm`, `ai.ocr`                | Chat, summarisation, document upload                      |
| Docs                         | `ai.llm`                          | Writing assistance, block notes                           |
| Bureaublad                   | `ai.llm`                          | Assistant in the dashboard                                |
| Messages                     | `ai.llm`                          | AI summaries and auto-labelling                           |
| Meet                         | `ai.llm`, `ai.whisperx`, `ai.stt` | Meeting summaries, recording transcription, live captions |
| Dictaphone                   | `ai.dictaphone`                   | Transcription jobs on an external Meeting Summary API     |
| Ollama                       | `application.ollama`              | Optional in-cluster demo LLM behind `ai.llm`              |

## Configuring a language model

`ai.llm` is a single OpenAI-compatible chat completions endpoint shared by all
applications:

```yaml
ai:
  llm:
    model: mistral-small-latest
    endpoint:
      host: api.mistral.ai
      port: ~ # empty uses the default HTTPS port
      path: "v1" # appended as <scheme>://<host>/<path>
      isSsl: true
      isInternal: false # true when the endpoint is reachable inside the cluster
    apiKey: "..." # store in a SOPS-encrypted secrets file
```

`host` may contain path segments (the demo uses `openrouter.ai/api` with `path: v1`).
Set `isInternal: true` when the endpoint runs in the cluster: it adds a NetworkPolicy
egress rule to the in-cluster service and keeps Conversations from base64-inlining
attachments.

Provider examples:

```yaml
# Mistral (EU-hosted)
ai:
  llm:
    model: mistral-small-latest
    endpoint:
      host: api.mistral.ai
      path: "v1"

# VLAM.ai (SSC-ICT, Dutch government)
ai:
  llm:
    model: <model-from-the-portal>
    endpoint:
      host: api.demo.vlam.ai
      path: "v2.1/projects/<project>/openai-compatible/v1"

# OpenRouter
ai:
  llm:
    model: mistralai/ministral-3b-2512
    endpoint:
      host: openrouter.ai/api
      path: "v1"

# Bundled Ollama
application:
  ollama:
    enabled: true
    model: llama3.2:1b
```

For VLAM.ai, the developer portal issues a project-scoped API key and an
OpenAI-compatible base URL of the form
`https://api.<environment>.vlam.ai/v2.1/projects/<project>/openai-compatible/v1`. Put
that URL in `host`/`path` as shown and use the key as `ai.llm.apiKey`. VLAM.ai exposes
chat completions; OCR and transcription still need a provider that offers those
endpoints.

## OCR for document uploads

Conversations can OCR PDFs that users attach to a chat. The request path is:

```
conversations → conversations-ocr-shim → OpenAI-compatible chat completions with a file parser
```

Conversations speaks the Mistral OCR schema. The shim rewrites that request into a chat
completion that sends the PDF to a `file-parser` plugin, and maps the parsed markdown back
into the OCR response. That means the upstream is not the OCR endpoint itself, but a chat
completions endpoint whose file parser supports the `mistral-ocr` engine.

```yaml
ai:
  ocr:
    enabled: true
    model: "mistral-ocr-latest" # sent to conversations, informational for the shim
    chatModel: "mistralai/ministral-3b-2512" # cheap model used for the wrapper call
    endpoint: "https://openrouter.ai/api/v1/chat/completions"
    apiKey: "..." # falls back to ai.llm.apiKey
```

Mistral OCR is one option for this: it preserves tables, headers and reading order, and
supports PDF, DOCX, PPTX and images, which makes it suitable for Dutch and English
documents. The default configuration reaches it through OpenRouter's `file-parser` plugin,
which keeps the OCR engine and the chat wrapper with the same provider and is what the
shim is written for. Pointing `ai.ocr.endpoint` directly at Mistral's `/v1/ocr` does not
work, because the shim sends chat completions rather than OCR requests; use the OpenRouter
route or adapt the shim.

When OCR is enabled, the `conversations-ocr-shim` release is deployed and the upload
feature is switched on (`documents.upload.enabled`).

## Batch transcription of recordings

Meet records meetings and hands the audio to the summary service, which calls a
WhisperX-compatible endpoint:

```yaml
ai:
  whisperx:
    baseUrl: https://api.openai.com/v1
    apiKey: "..."
    asrModel: gpt-4o-transcribe-diarize
    defaultLanguage: ~ # defaults to global.defaultLocale
    shim: true # deploy meet-openai-shim in front of an OpenAI-style API
```

With `shim: true` MijnBureau deploys `meet-openai-shim`, which rewrites the WhisperX-style
request into an OpenAI `audio/transcriptions` call with diarization. The demo environment
uses this with OpenAI.

Mistral's Voxtral Mini Transcribe 2 (`voxtral-mini-latest`) is one EU-hosted option for
this job; it supports speaker diarization, word-level timestamps and recordings up to
three hours.

```yaml
ai:
  whisperx:
    shim: true
    baseUrl: https://api.mistral.ai/v1
    asrModel: voxtral-mini-latest
    apiKey: "..."
```

The bundled shim is written for OpenAI's response format: it forces
`response_format=diarized_json` and `chunking_strategy=auto`. Check that your provider
accepts those fields, or run a WhisperX-compatible endpoint without the shim and point
`baseUrl` at it directly. Dictaphone uses the same summary service, so this setting also
covers Dictaphone transcription jobs.

## Real-time transcription during meetings

Live captions in Meet are produced by a LiveKit agent and configured separately from the
batch transcription:

```yaml
ai:
  stt:
    provider: voxtral-vllm # deepgram | kyutai | voxtral-vllm
    deepgram:
      apiKey: "..."
      model: nova-3
      language: multi
    kyutai:
      baseUrl: "..."
      apiKey: "..."
    voxtral:
      baseUrl: "..."
      apiKey: "..."
      model: voxtral-mini-4b-realtime-2602
      targetStreamingDelayMs: 480
```

Set `provider` explicitly. The shipped default is `voxtral`, while the chart wires the
self-hosted path under `voxtral-vllm`; with `voxtral` the agent gets no endpoint
variables. Valid values are `deepgram`, `kyutai` and `voxtral-vllm`.

For a fully self-hosted, EU-only setup, serve Voxtral Realtime (Apache 2.0) on vLLM,
expose it in the cluster and use `provider: voxtral-vllm` with the service URL. Deepgram
and Kyutai are hosted alternatives.

## Dictaphone

Dictaphone posts transcription jobs to a Meeting Summary API:

```yaml
ai:
  dictaphone:
    serviceUrl: ~ # defaults to the in-cluster meet-summary service
    serviceApiKey: "..."
    webhookApiKey: "..."
```

Leave `serviceUrl` empty to use the Meet summary service deployed by MijnBureau, which
reuses `ai.llm` and `ai.whisperx`. Set it only when Dictaphone should send jobs to an
external service.

## Secret handling

API keys belong in the environment's secrets file, not in the values files. MijnBureau
supports SOPS-encrypted secrets through helm-secrets; see [Secrets](../operating/secrets/sops.md) for the
pattern. The demo environment keeps them in
`helmfile/environments/demo/fundament.secrets.yaml`.

## Choosing a provider

The table lists options that are known to fit each configuration shape. It is not a
ranking or a recommendation: choose a provider based on your own requirements (data
residency, contract terms, quality, cost) and verify it against the interface described
above.

| Job                      | Example options                    | Notes                                      |
| ------------------------ | ---------------------------------- | ------------------------------------------ |
| Chat, summaries, writing | VLAM.ai, Mistral, OpenRouter       | Any OpenAI-compatible chat endpoint        |
| OCR                      | Mistral OCR (`mistral-ocr-latest`) | Via the shim and an OpenRouter file parser |
| Batch transcription      | Mistral Voxtral, OpenAI            | Diarization for meeting recordings         |
| Real-time transcription  | Self-hosted Voxtral on vLLM        | No audio leaves the cluster                |
| Demo / air-gapped        | Ollama                             | Small model, demo quality only             |

Combining VLAM.ai or Mistral for chat, Mistral OCR for documents and Voxtral for speech is
one way to get an EU-hosted setup. For air-gapped clusters, Ollama plus self-hosted Voxtral
keeps all inference in the cluster; see [Ollama](./ollama.md) for sizing.
Neither combination is required or preferred by MijnBureau.

## Verifying

Check what an application received:

```bash
kubectl -n mijnbureau-docs exec deploy/docs-backend -- env | grep '^AI_'
kubectl -n mijnbureau-meet exec deploy/meet-summary -- env | grep -E 'LLM_|WHISPERX_'
kubectl -n mijnbureau-conversations get deploy conversations-ocr-shim
```

If AI features stay hidden, `ai.llm.model` or `ai.llm.endpoint.host` is empty. If
document upload fails, check the `conversations-ocr-shim` logs. If summaries appear without
a transcript, the `ai.whisperx` endpoint is unreachable.
