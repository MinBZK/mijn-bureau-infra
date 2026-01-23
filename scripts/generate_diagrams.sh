#!/usr/bin/env bash

# This script formats the codebase using Prettier.
# Usage: ./scripts/generate_diagrams.sh

# Check if gitlint is installed
if ! command -v helmfile &> /dev/null; then
  echo "helmfile could not be found. Please install it."
  exit 1
fi

helmfile -e demo template > example.yaml

# Check if gitlint is installed
if ! command -v kube-diagrams &> /dev/null; then
  echo "kube-diagrams could not be found. Please install it."
  exit 1
fi

namespaces=(
  grist
  ollama
  keycloak
  element
  collabora
  nextcloud
  livekit
  meet
  conversations
  docs
  bureaublad
  drive
  clamav
)

for ns in "${namespaces[@]}"; do
  kube-diagrams -n "$ns" -o "diagrams/${ns}.png" example.yaml
done
