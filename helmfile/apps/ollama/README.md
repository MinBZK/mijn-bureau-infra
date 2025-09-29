# Ollama

This directory contains the helmfile for [Ollama](https://github.com/ollama/ollama), a lightweight
framework for building and running LLMs locally. The helmfile is esentially a wrapper around the
Ollama helm chart from [OTWLD](https://github.com/otwld/ollama-helm).

## Purpose

**⚠️ DEMO USE ONLY: The default llama3.2:1b model is NOT suitable for production or serious use cases. ⚠️**

The purpose of the locally deployed LLM and AI endpoint in this product is solely for
_demo purposes_. For this reason an extremely lightweight model is chosen: llama3.2:1b.

This model has only 1 billion parameters, making it very limited in reasoning capabilities and unsuitable for complex tasks, coding assistance, or production workloads. The small size of this model (1.3GB) means it fits easily into memory, but comes at the cost of significantly reduced capabilities.

## Implementation notes

Ollama needs to be able to download the llama3.2:1b model and for this an egress must be allowed on
port 443; the network policy for this is automatically executed by the hemlfile.

To allow the Ollama API to be reachable within the namespace the helmfile is deployed in, egress and
ingress on port 11434 must be allowed; the network policy for this is automatically executed by the
helmfile.
