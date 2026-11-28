# ADR-MB-020: AI provider architecture

## Status

Accepted

## Context

AI is used for four distinct jobs: chat and writing assistance, OCR of uploaded documents,
batch transcription of recordings, and real-time transcription in meetings. Every job has
different requirements: chat needs a capable LLM, OCR needs a document parser, batch
transcription needs diarization, and real-time transcription needs low latency.

Providers differ in availability, data residency and API shape. Bundling one vendor's SDK
into each application would make providers hard to swap and would spread credentials across
charts. Customers increasingly need European or self-hosted inference.

## Decision

We will standardise on OpenAI-compatible HTTP APIs, configured per capability under `ai.*`.

- `ai.llm` — one chat completions endpoint shared by Conversations, Docs, Bureaublad,
  Messages and Meet summaries.
- `ai.ocr` — Conversations speaks the Mistral OCR schema; the in-cluster `ocr-shim`
  translates it into an OpenAI-compatible chat completion with a document parser.
- `ai.whisperx` — batch transcription through a WhisperX-compatible endpoint; the
  `meet-openai-shim` translates requests for providers that only expose OpenAI's audio
  transcription API.
- `ai.stt` — real-time transcription provider for the LiveKit agent (`deepgram`, `kyutai`,
  `voxtral-vllm`).
- Ollama remains an optional in-cluster demo provider; it is not a production default.

Schemas are translated in small shims in this repository rather than by patching upstream
applications, so applications stay on their release cadence.

## Consequences

**Pros:**

- ✅ Providers can be swapped per capability without touching application code.
- ✅ European (Mistral, VLAM.ai) and self-hosted (vLLM, Ollama) options fit the same
  configuration shape.
- ✅ Credentials live in one `ai` block instead of being duplicated per chart.

**Cons:**

- ❌ Two small shims must be maintained and kept compatible with upstream applications.
- ❌ Providers that are not OpenAI-compatible need either a shim or are unsupported.
- ❌ Data leaves the cluster unless every capability is self-hosted.
- ❌ Quality and cost depend on the chosen provider; there is no bundled model guarantee.
