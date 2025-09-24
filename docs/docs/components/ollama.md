# Ollama - AI LLM

MijnBureau supplies an installation of [Ollama](https://ollama.com/). Ollama is a lightweight
framework for building and running LLMs locally

## Purpose

:::warning Demo Use Only
The default llama3.2:1b model is **NOT suitable for production or serious use cases**. This model has very limited reasoning capabilities and is intended **exclusively for demonstration and testing purposes**.
:::

The purpose of the locally deployed LLM and AI endpoint in this product is solely for
_demo purposes_. For this reason an extremely lightweight model is chosen: [llama3.2:1b](https://ollama.com/library/llama3.2:1b).

This model has only 1 billion parameters, making it:

- **Very limited** in reasoning and analytical capabilities
- **Unsuitable** for complex tasks, coding assistance, or production workloads
- **Intended only** to demonstrate that AI integration works

The small size of this model (1.3GB) means it fits easily into memory, but comes at the cost of significantly reduced capabilities compared to larger, more capable models.

## Implementation notes

Ollama needs to be able to download the llama3.2:1b model and requires internet access to do so.

## Configuration

To configure this solution, you can override the default settings for your environment. The defaults are
located in the folder `helmfile/environments/default`.

| Name                       | Description                          |
| -------------------------- | ------------------------------------ |
| `application.ai.enabled`   | Enable Ollama                        |
| `application.ai.namespace` | The Kubernetes namespace name        |
| `container.ollama.*`       | Container settings to overwrite      |
| `ai.selfhost.*`            | Applicatoin configuration for ollama |
| `resource.ollama.*`        | Resource configuration               |
| `pvc.ollama.*`             | Storage configuration                |

## Performance Requirements

For smooth ~5 second responses with llama3.2:1b (1.3GB model):

### Single User

- **CPU**: 2-4 cores (modern processors, 2GHz+)
- **Memory**: 3-4GB RAM (1.3GB model + runtime overhead)
- Current defaults (400m CPU request, 2Gi memory) may be insufficient for consistent 5s responses

### Multiple Users (~5 simultaneous)

- **CPU**: 6-8 cores or configure `OLLAMA_NUM_PARALLEL`
- **Memory**: 6-8GB RAM (shared model + multiple request contexts)
- Consider horizontal autoscaling (already configured in helmfile)

### Configuration Options

You can tune Ollama's performance using environment variables in your helmfile configuration:

```yaml
container:
  ollama:
    extraEnv:
      - name: OLLAMA_NUM_PARALLEL
        value: "4" # Controls parallel requests per model
      - name: OLLAMA_MAX_QUEUE
        value: "512" # Maximum queued requests
      - name: OLLAMA_MAX_LOADED_MODELS
        value: "1" # Maximum concurrent models
```

Resource limits can be adjusted via `resource.ollama.*` in your helmfile values.

## Your own AI LLM

If you do not want to deploy Ollama but want to use your own AI system disable ollama by setting `application.ai.enabled` and configure your AI endspoint in `ai.llm.*`.
