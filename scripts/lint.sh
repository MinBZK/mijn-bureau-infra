#!/usr/bin/env bash

# This script lints the commit message
# Usage: ./scripts/format.sh

# Check if gitlint is installed
if ! command -v gitlint &> /dev/null; then
  echo "gitlint could not be found. Please install it. For more information visit https://jorisroovers.com/gitlint/latest/"
  exit 1
fi

gitlint
helmfile lint
