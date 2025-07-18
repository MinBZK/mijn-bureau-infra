#!/usr/bin/env bash

# This script formats the codebase using Prettier.
# Usage: ./scripts/test.sh -p <path>

# Default values
ENVIRONMENTS="default"

# Parse options
while getopts "e:" opt; do
  case $opt in
    e)
      ENVIRONMENTS="$OPTARG"
      ;;
    *)
      echo "Usage: $0 [-p path] [-e environments]"
      exit 1
      ;;
  esac
done

export MIJNBUREAU_MASTER_PASSWORD=$(cat /run/secrets/mijnbureau-master-password 2>/dev/null || echo "default_password")


# Check if Prettier is installed
if ! command -v conftest &> /dev/null; then
  echo "conftest could not be found. Please install it. For more information visit https://www.conftest.dev/install/"
  exit 1
fi

if ! command -v helmfile &> /dev/null; then
  echo "helmfile could not be found. Please install it. For more information visit https://helmfile.readthedocs.io/en/latest/#installation"
  exit 1
fi

RANDOM_DIR=$(mktemp -d)
echo "Created random folder: $RANDOM_DIR"
helmfile -e $ENVIRONMENTS template --output-dir=$RANDOM_DIR
if [ $? -ne 0 ]; then
  echo "Failed to render Helmfile templates. Please check your Helmfile configuration."
  exit 1
fi

find $RANDOM_DIR -type f -name "*.yaml.gotmpl" | while read file; do
  mv "$file" "${file%.gotmpl}"
done




# Format the codebase using Prettier
echo "testing codebase with conftest..."
conftest test "$RANDOM_DIR"
