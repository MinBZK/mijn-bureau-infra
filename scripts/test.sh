#!/usr/bin/env bash

# This script tests Helm templates using Conftest policy validation
# Usage: $0 [-e environment] [-s secret]

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

# Make parsed values readonly to prevent accidental modification
readonly ENVIRONMENT
readonly SECRET

export MIJNBUREAU_MASTER_PASSWORD=test
export SOPS_AGE_KEY="$SECRET"

# Set conftest output format for GitHub Actions
CONFTEST_OPTIONS=""
if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  CONFTEST_OPTIONS="--output github"
fi
readonly CONFTEST_OPTIONS

# Arrays for tracking test processes and results
pids=()
failed_tests=()
declare -A test_names

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly CYAN='\033[0;36m'
readonly BOLD_GREEN='\033[1;32m'
readonly BOLD_RED='\033[1;31m'
readonly NC='\033[0m' # No Color

# Signal handler for cleanup - ensures background processes are terminated
cleanup() {
  if [ ${#pids[@]} -gt 0 ]; then
    printf -- "\nCleaning up %d background processes...\n" "${#pids[@]}"
    for pid in "${pids[@]}"; do
      if kill -0 "$pid" 2>/dev/null; then
        kill -TERM "$pid" 2>/dev/null || true
        sleep 1
        # Force kill if still running
        kill -0 "$pid" 2>/dev/null && kill -KILL "$pid" 2>/dev/null || true
      fi
    done
  fi
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Run a single test in an isolated environment
run_single_test() {
  local env_file="$1"
  local test_name
  local log_file
  local abs_env_file
  local abs_policy_folder
  local tmpdir

  test_name=$(basename "$env_file" .yaml)
  log_file="/tmp/test_${test_name}_$$.log"

  # Capture absolute paths before changing directories
  abs_env_file=$(realpath "$env_file")
  abs_policy_folder=$(realpath "${env_file%.*}")

  exec > "$log_file" 2>&1

  tmpdir=$(mktemp -d)
  cp -r . "${tmpdir}/mijnbureau"
  cd "${tmpdir}/mijnbureau" || exit 1

  # Replace the environment configuration with our test configuration
  rm -f "helmfile/environments/${ENVIRONMENT}/"*.yaml.gotmpl
  cp -f "$abs_env_file" "helmfile/environments/${ENVIRONMENT}/mijnbureau.yaml.gotmpl"

  # Skip deps to avoid registry login race conditions between parallel tests
  # Use --quiet to suppress verbose "wrote file.yaml" output for cleaner test results
  if ! helmfile -e "$ENVIRONMENT" template --output-dir="${tmpdir}/output" --skip-deps --quiet; then
    printf -- "${RED}FAILED: Error processing environment file: %s${NC}\n" "$abs_env_file"
    printf -- "${RED}Processing environment %s in %s/output${NC}\n" "$ENVIRONMENT" "$tmpdir"
    exit 1
  fi

  # Run policy tests if policy directory exists
  if [ -d "$abs_policy_folder" ]; then
    local rego_files=("$abs_policy_folder"/*.rego)
    if [ ! -f "${rego_files[0]}" ]; then
      printf -- "WARNING: No .rego policy files found in %s\n" "$abs_policy_folder"
    else
      local test_failed=false
      local policy_file
      for policy_file in "$abs_policy_folder"/*.rego; do
        if [ -f "$policy_file" ]; then
          # Extract just the .rego filename
          policy_display_name=$(basename "$policy_file")
          printf -- "Running policy: %s\n" "$policy_display_name"
          conftest test "${tmpdir}/output" --policy "$policy_file" --parser yaml $CONFTEST_OPTIONS | sed '1{/^$/d;}'
          if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            printf -- "FAILED: Policy test failed for file: %s\n" "$abs_env_file"
            printf -- "policy_file: %s\n" "$policy_file"
            test_failed=true
          fi
        fi
      done
      if [ "$test_failed" = "true" ]; then
        exit 1
      fi
      # Policy tests completed successfully - no verbose output needed
    fi
  else
    printf -- "WARNING: Policy directory %s not found\n" "$abs_policy_folder"
  fi

  # Cleanup temp directory
  rm -rf "$tmpdir"
}

# Start all test processes in parallel
printf -- "🔄 Initializing test suites...\n"
for env_file in tests/*.yaml; do
  if [ -f "$env_file" ]; then
    printf -- "   ✓ %s\n" "$(basename "$env_file" .yaml)"
    run_single_test "$env_file" &
    pid=$!
    pids+=("$pid")
    test_names[$pid]=$(basename "$env_file" .yaml)
  fi
done

printf -- "Started %d test processes...\n\n" "${#pids[@]}"

# Collect results from all processes
exit_code=0
for pid in "${pids[@]}"; do
  test_name="${test_names[$pid]}"
  log_file="/tmp/test_${test_name}_$$.log"

  # Show output from this test with consistent 80-char formatting
  if [ -f "$log_file" ]; then
    if wait "$pid"; then
      printf -- "================================================================================\n"
      printf -- "${BOLD_GREEN}✅ PASSED: %s${NC}\n" "$test_name"
      printf -- "================================================================================\n"
    else
      printf -- "================================================================================\n"
      printf -- "${BOLD_RED}❌ FAILED: %s${NC}\n" "$test_name"
      printf -- "================================================================================\n"
      failed_tests+=("$test_name")
      exit_code=1
    fi
    cat "$log_file"
    printf -- "================================================================================\n"
    rm -f "$log_file"
  else
    if wait "$pid"; then
      printf -- "${BOLD_GREEN}✅ PASSED: %s${NC}\n" "$test_name"
    else
      printf -- "${BOLD_RED}❌ FAILED: %s${NC}\n" "$test_name"
      failed_tests+=("$test_name")
      exit_code=1
    fi
  fi
  printf "\n"
done

# Final summary
printf -- "${CYAN}################################################################################${NC}\n"
printf -- "${CYAN}                               TEST SUMMARY                                   ${NC}\n"
printf -- "${CYAN}################################################################################${NC}\n"
printf -- "Total tests: %d  |  ${BOLD_GREEN}Passed: %d${NC}  |  ${BOLD_RED}Failed: %d${NC}\n" "${#pids[@]}" "$((${#pids[@]} - ${#failed_tests[@]}))" "${#failed_tests[@]}"

if [ "${#failed_tests[@]}" -gt 0 ]; then
  printf -- "\n${BOLD_RED}Failed tests:${NC}\n"
  for test in "${failed_tests[@]}"; do
    printf -- "  ${RED}- %s${NC}\n" "$test"
  done
fi
printf -- "${CYAN}################################################################################${NC}\n"

exit "$exit_code"
