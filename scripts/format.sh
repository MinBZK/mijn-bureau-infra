#!/usr/bin/env bash

# This script formats the codebase using Prettier.
# Usage: ./scripts/format.sh

# Check if Prettier is installed
if ! command -v prettier &> /dev/null; then
  echo "Prettier could not be found. Please install it. For more information visit https://prettier.io/docs/install"
  exit 1
fi

# Format the codebase using Prettier
echo "Formatting codebase with Prettier..."
prettier --write .
