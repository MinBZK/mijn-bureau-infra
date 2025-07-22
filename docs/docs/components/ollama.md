# Ollama

The directory `helmfile/apps/ollama/` contains the helmfile for [Ollama](https://github.com/ollama/ollama), a lightweight
framework for building and running LLMs locally. The helmfile is esentially a wrapper around the
Ollama helm chart from [OTWLD](https://github.com/otwld/ollama-helm).

## Purpose

The purpose of the locally deployed LLM and AI endpoint in this product is solely for
_demo purposes_. For this reason an extremely lightweight model is chosen: Lamma 3.2. The small
size of this models (2GB) means that this model easily fits into memory in most scenario's but is
also essentially useless for situations other than a demo.

## Implementation notes

Ollama needs to be able to download the Lamma 3.2 model and for this an egress must be allowed on
port 443; the network policy for this is automatically executed by the hemlfile.

To allow the Ollama API to be reachable within the namespace the helmfile is deployed in, egress and
ingress on port 11434 must be allowed; the network policy for this is automatically executed by the
helmfile.
