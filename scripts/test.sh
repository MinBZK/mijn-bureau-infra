#!/usr/bin/env bash

# This script tests the code using Conftest
# Usage: ./scripts/test.sh [-p path] [-e environments] [-s secret]

# Default values
ENVIRONMENT="demo"
SECRET=""

# Parse options
while getopts "e:s:" opt; do
  case $opt in
    e)
      ENVIRONMENT="$OPTARG"
      ;;
    s)
      SECRET="$OPTARG"
      ;;
    *)
      echo "Usage: $0 [-p path] [-e environments] [-s secret]"
      exit 1
      ;;
  esac
done

# Check if Conftest is installed
if ! command -v conftest &> /dev/null; then
  echo "conftest could not be found. Please install it. For more information visit https://www.conftest.dev/install/"
  exit 1
fi

# Check if Helmfile is installed
if ! command -v helmfile &> /dev/null; then
  echo "helmfile could not be found. Please install it. For more information visit https://helmfile.readthedocs.io/en/latest/#installation"
  exit 1
fi

export MIJNBUREAU_MASTER_PASSWORD=test
export SOPS_AGE_KEY=$SECRET

CONFTEST_OPTIONS=""
if [ "$GITHUB_ACTIONS" = "true" ]; then
  CONFTEST_OPTIONS="--output github"
fi

pids=()

for env_file in tests/*.yaml; do
  if [ -f "$env_file" ]; then
    echo "Processing environment file: $env_file. this may take a while..."
    (
      TMPDIR=$(mktemp -d)
      cp -r . ${TMPDIR}/mijnbureau
      cd ${TMPDIR}/mijnbureau
      rm helmfile/environments/${ENVIRONMENT}/*.yaml.gotmpl
      cp -f "$env_file" helmfile/environments/${ENVIRONMENT}/mijnbureau.yaml.gotmpl
      echo  "Processing environment ${ENVIRONMENT} in ${TMPDIR}/output"
      helmfile -e ${ENVIRONMENT} template --output-dir="${TMPDIR}/output" 2>/dev/null
      if [ $? -ne 0 ]; then
        echo "Error processing environment file: $env_file"
        exit 1
      else
        echo "Successfully processed environment file: $env_file"
        policy_folder="${env_file%.*}"
        if [ -d "$policy_folder" ]; then
          for policy_file in "$policy_folder"/*.rego; do
            conftest test "${TMPDIR}/output" --policy "$policy_file" --parser yaml $CONFTEST_OPTIONS
            if [ $? -ne 0 ]; then
              echo "Policy test failed for file: $env_file"
              echo "policy_file: $policy_file"
              exit 1
            fi
          done
          echo "Successfully processed policy for: $env_file"
        fi
      fi
    ) &
    pids+=($!)
  fi
done

# Wait for all background processes to complete
for pid in "${pids[@]}"; do
  wait $pid
  if [ $? -ne 0 ]; then
    echo "One or more tests failed"
    exit 1
  fi
done
