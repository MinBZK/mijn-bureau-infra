#!/usr/bin/env bash

# This script generates value file schemas for all applications
# Usage: ./scripts/format.sh

# check helm installed
if ! command -v helm &> /dev/null; then
  echo "Error: helm is not installed. Please install helm to run this script."
  exit 1
fi

# check if helm plugin is installed
if ! helm plugin list | grep -q "schema"; then
  echo "Error: helm schema plugin is not installed. Please install it to run this script."
  echo "helm plugin install https://github.com/losisin/helm-values-schema-json.git"
  exit 1
fi


if [[ ! -d "helmfile/apps" ]]; then
  echo "Error: helmfile/apps directory not found"
  exit 1
fi

charts=$(find helmfile/apps -name "Chart.yaml" -type f)

# itterate over every directory in helmfiles/apps/ that includes a charts directory
for chart in $charts; do
  dir=$(dirname "$chart")
  echo "Generating schema for $dir"

  # check if values.yaml exists in the directory
  if [[ -f "$dir/values.yaml" ]]; then
    helm schema --indent 2 -f "$dir/values.yaml"
    mv "values.schema.json" "$dir/values.schema.json"
  else
    echo "No values.yaml found in $dir, skipping schema generation."
  fi
done
