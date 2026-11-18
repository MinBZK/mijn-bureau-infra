# Transcription

MijnBureau includes **Dictaphone** (Assistant Transcripts), the transcription and meeting
workflow application from LaSuite. Users record in-person meetings or upload audio, and the
platform returns a transcript that can be reviewed, edited and shared.

![Transcription preview](/img/features/transcription.png)

## What you can do

- Record a meeting in the browser, or upload an existing recording.
- Generate transcripts in the configured language, with speaker diarization where the
  provider supports it.
- Review and correct transcripts before sharing them.
- Send recordings from Meet to the same transcription pipeline.

## Configuration

Transcription is one of the [AI services](./ai-services.md) and depends on a transcription
backend:

- `ai.whisperx.*` configures batch transcription for Meet recordings and Dictaphone jobs.
- `ai.dictaphone.*` points Dictaphone at a Meeting Summary API. Leave `serviceUrl` empty to
  use the in-cluster Meet summary service.
- `application.dictaphone.enabled` deploys Dictaphone itself.

Dictaphone is disabled by default. Without a configured backend, recordings can still be
managed but new transcription jobs cannot be processed.

- [Dictaphone component documentation](../components/dictaphone.md)
- [AI services and provider choices](./ai-services.md)
