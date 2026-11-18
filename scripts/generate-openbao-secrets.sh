#!/usr/bin/env bash
#
# generate-openbao-secrets.sh
#
# Generates every MijnBureau secret and writes it to OpenBao KV v2.
#
# This replaces the previous deterministic `derivePassword` model: instead of
# deriving passwords from a single MIJNBUREAU_MASTER_PASSWORD, each secret is a
# freshly generated random value stored in OpenBao and synced into Kubernetes by
# External Secrets Operator (ESO).
#
# Losing existing data is assumed acceptable: this script generates NEW random
# values. Run it against a fresh cluster, or with --force to rotate (which will
# break existing DB/app access until the apps are restarted against the new
# values).
#
# Usage:
#   export BAO_ADDR=https://openbao.example.internal
#   export BAO_TOKEN=<token-with-write-on-secret/mijnbureau/*>
#   ./scripts/generate-openbao-secrets.sh [--env demo] [--force] [--dry-run]
#
# OpenBao path scheme (KV v2, mount "secret"):
#   secret/data/mijnbureau/<env>/<owner>/<key>
#
# Where <owner> is the app namespace and <key> is the individual secret. Shared
# secrets (e.g. Keycloak client secrets, calendars<->messages channel keys) are
# stored once under their owner path and read by every consumer, so both sides
# observe the same value.
#
# Env:
#   BAO_ADDR       OpenBao address (required)
#   BAO_TOKEN      Token with write access to secret/mijnbureau/<env>/* (required)
#   MIJNBUREAU_ENV Environment name (default: demo)
#   BAO_NAMESPACE  Optional OpenBao namespace

set -euo pipefail

ENV="${MIJNBUREAU_ENV:-demo}"
FORCE=0
DRY_RUN=0

usage() {
  sed -n '2,31p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env|-e) ENV="${2:?--env requires a value}"; shift 2 ;;
    --force|-f) FORCE=1; shift ;;
    --dry-run|-n) DRY_RUN=1; shift ;;
    --help|-h) usage ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

for bin in bao openssl sort; do
  command -v "$bin" >/dev/null 2>&1 || { echo "missing required binary: $bin" >&2; exit 1; }
done

if [[ "$DRY_RUN" -eq 0 ]]; then
  : "${BAO_ADDR:?BAO_ADDR is required — set it to the OpenBao address}"
  : "${BAO_TOKEN:?BAO_TOKEN is required — a token with write access to secret/mijnbureau/<env>/*}"
  export VAULT_ADDR="${BAO_ADDR}"   # bao honours BAO_ADDR; also export Vault-compatible fallback
  export VAULT_TOKEN="${BAO_TOKEN}"
fi

MOUNT="${BAO_KV_MOUNT:-secret}"
PREFIX="${MOUNT}/mijnbureau/${ENV}"

# ---------------------------------------------------------------------------
# Format generators. Each produces the value in its FINAL form (the apps
# consume these exact strings; no sha1sum/trunc/b64enc pipeline is reproduced).
# ---------------------------------------------------------------------------
hex() { openssl rand -hex "$1"; }

gen_hex40()  { hex 20; }                                      # 40 hex  (old sha1sum)
gen_hex32()  { hex 16; }                                      # 32 hex  (old sha256|trunc 32)
gen_hex50()  { hex 25; }                                      # 50 hex  (old sha256|trunc 50)
gen_hex22()  { hex 11; }                                      # 22 hex  (old sha256|trunc 22)
gen_django63(){ hex 32 | cut -c1-63; }                        # 63 hex  (Django SECRET_KEY)
gen_msgk()   { printf 'msgk_%s' "$(hex 32)"; }                # msgk_ + 64 hex
# Fernet keys = 32 bytes base64-encoded. Two historical spellings; both decode to 32 bytes.
gen_fernet_b64() { printf '%s' "$(hex 16)" | base64; }        # b64(32 hex chars) -> 44 chars
gen_fernet_43()  { printf '%s=' "$(hex 22 | cut -c1-43)"; }   # 43 hex chars + "=" -> 44 chars
gen_placeholder(){ hex 32; }                                  # 64 hex (operator replaces later)

# ---------------------------------------------------------------------------
# Secret catalogue: owner<TAB>key<TAB>format
# Formats: hex40 hex32 hex50 hex22 django63 msgk fernet_b64 fernet_43 placeholder
# ---------------------------------------------------------------------------
SECRETS=$(cat <<'EOF'
keycloak	adminPassword	hex40
keycloak	database	hex40
keycloak	database_admin	hex40
keycloak	meet_client_secret	hex40
keycloak	synapse_client_secret	hex40
keycloak	mas_client_secret	hex40
keycloak	nextcloud_client_secret	hex40
keycloak	conversations_client_secret	hex40
keycloak	docs_client_secret	hex40
keycloak	bureaublad_client_secret	hex40
keycloak	drive_client_secret	hex40
keycloak	projects_client_secret	hex40
keycloak	people_client_secret	hex40
keycloak	calendars_client_secret	hex40
keycloak	dictaphone_client_secret	hex40
keycloak	messages_client_secret	hex40
keycloak	menshen_client_secret	hex40
collabora	adminPassword	hex40
nextcloud	adminPassword	hex40
nextcloud	database	hex40
nextcloud	database_admin	hex40
nextcloud	password	hex40
meet	adminPassword	hex40
meet	summaryApiToken	hex40
meet	summaryWebhookApiToken	hex40
meet	database	hex40
meet	database_admin	hex40
meet	password	hex40
meet	secretkey	hex40
conversations	adminPassword	hex40
conversations	secretkey	hex40
conversations	oidc-refresh-token-key	fernet_b64
conversations	database	hex40
conversations	database_admin	hex40
conversations	password	hex40
docs	superUserPassword	hex40
docs	database	hex40
docs	database_admin	hex40
docs	password	hex40
docs	serverToServerApiToken	hex40
docs	djangoSecretKey	django63
docs	yProviderKey	hex40
docs	oidcStoreRefreshTokenKey	fernet_b64
drive	adminPassword	hex40
drive	database	hex40
drive	database_admin	hex40
drive	password	hex40
drive	secretkey	hex40
drive	secrettoServerKey	hex40
drive	oidcStoreRefreshTokenKey	fernet_b64
find	superUserPassword	hex40
find	database	hex40
find	database_admin	hex40
find	password	hex40
find	secretkey	hex40
find	opensearch	hex40
find	serviceTokenDocs	hex50
find	serviceTokenDrive	hex50
find	menshenClientFind	hex40
find	menshenClientDocs	hex40
find	menshenClientDrive	hex40
find	menshenClientBureaublad	hex40
menshen	superUserPassword	hex40
menshen	database	hex40
menshen	database_admin	hex40
menshen	password	hex40
menshen	secretkey	hex40
menshen	tokenHashKey	hex40
projects	adminPassword	hex40
projects	database	hex40
projects	database_admin	hex40
projects	password	hex40
projects	secretkey	hex40
people	adminPassword	hex40
people	database	hex40
people	database_admin	hex40
people	password	hex40
people	secretkey	hex40
calendars	adminPassword	hex40
calendars	database	hex40
calendars	database_admin	hex40
calendars	password	hex40
calendars	secretkey	hex40
calendars	saltkey	hex40
calendars	caldav_inbound	hex40
calendars	caldav_outbound	hex40
calendars	caldav_internal	hex40
calendars	messages-caldav-channel-id	hex22
calendars	messages-caldav-channel-token	hex40
calendars	messages-calendars-channel-id	hex32
calendars	messages-calendars-channel-api-key	msgk
dictaphone	adminPassword	hex40
dictaphone	database	hex40
dictaphone	database_admin	hex40
dictaphone	password	hex40
dictaphone	secretkey	hex40
dictaphone	jwtSigningKey	hex40
dictaphone	audioExtractorTranscodingToken	hex40
dictaphone	audioExtractorValidationToken	hex40
dictaphone	aiServiceApiKey	hex40
dictaphone	aiWebhookApiKey	hex40
messages	adminPassword	hex40
messages	secretkey	hex40
messages	saltkey	hex40
messages	mdaApiSecret	hex40
messages	oidc-refresh-token-key	fernet_43
messages	database	hex40
messages	database_admin	hex40
messages	password	hex40
messages	mtaRelayPassword	hex40
synapse	database	hex40
synapse	database_admin	hex40
synapse	password	hex40
synapse	registrationSharedSecret	hex40
synapse	formSecret	hex40
mas	database	hex40
mas	database_admin	hex40
mas	sharedSecret	hex40
lkjwt	asToken	hex40
lkjwt	hsToken	hex40
livekit	password	hex40
livekit	apikey	hex40
livekit	elementcall	hex40
bureaublad	password	hex40
bureaublad	secretkey	hex40
minio	nextcloud	hex40
minio	docs	hex40
minio	drive	hex40
minio	meet	hex40
minio	projects	hex40
minio	people	hex40
minio	dictaphone	hex40
minio	conversations	hex40
minio	messages	hex40
ai	llm_apiKey	placeholder
ai	whisperx_apiKey	placeholder
ai	ocr_apiKey	placeholder
livekit	meet_apiKey	placeholder
livekit	meet_apiSecret	placeholder
smtp	password	placeholder
EOF
)

# Generate each value into a temp file as: owner<TAB>key<TAB>value
TMPDIR_WORK=$(mktemp -d)
trap 'rm -rf "$TMPDIR_WORK"' EXIT
DATA_FILE="${TMPDIR_WORK}/secrets.tsv"
PLACEHOLDER_FILE="${TMPDIR_WORK}/placeholders.tsv"
: > "$DATA_FILE"
: > "$PLACEHOLDER_FILE"

while IFS=$'\t' read -r owner key fmt; do
  [[ -z "$owner" ]] && continue
  case "$fmt" in
    hex40)       value=$(gen_hex40) ;;
    hex32)       value=$(gen_hex32) ;;
    hex50)       value=$(gen_hex50) ;;
    hex22)       value=$(gen_hex22) ;;
    django63)    value=$(gen_django63) ;;
    msgk)        value=$(gen_msgk) ;;
    fernet_b64)  value=$(gen_fernet_b64) ;;
    fernet_43)   value=$(gen_fernet_43) ;;
    placeholder) value=$(gen_placeholder); printf '%s\t%s\n' "$owner" "$key" >> "$PLACEHOLDER_FILE" ;;
    *) echo "unknown format '$fmt' for $owner/$key" >&2; exit 1 ;;
  esac
  printf '%s\t%s\t%s\n' "$owner" "$key" "$value" >> "$DATA_FILE"
done <<< "$SECRETS"

# Sort by owner,key so each owner's keys are contiguous.
sort -t $'\t' -k1,1 -k2,2 "$DATA_FILE" -o "$DATA_FILE"

echo "== Generating secrets for environment '$ENV' =="

cur_owner=""
args=()
flush() {
  [[ -z "$cur_owner" ]] && return
  local path="${PREFIX}/${cur_owner}"
  local exists=0
  if [[ "$DRY_RUN" -eq 0 ]] && bao kv get "$path" >/dev/null 2>&1; then
    exists=1
  fi
  if [[ "$exists" -eq 1 && "$FORCE" -eq 0 ]]; then
    echo "  skip  $path (exists; use --force to regenerate)"
  elif [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  put   $path"
    local a
    for a in "${args[@]}"; do echo "        ${a%%=*} = ***"; done
  else
    # shellcheck disable=SC2068  # intentional word-splitting-free array expansion
    bao kv put "$path" "${args[@]}" >/dev/null
    echo "  wrote $path"
  fi
  args=()
}

while IFS=$'\t' read -r owner key value; do
  [[ -z "$owner" ]] && continue
  if [[ "$owner" != "$cur_owner" ]]; then
    flush
    cur_owner="$owner"
  fi
  args+=("$key=$value")
done < "$DATA_FILE"
flush

if [[ -s "$PLACEHOLDER_FILE" ]]; then
  echo
  echo "== PLACEHOLDERS (replace these with real credentials) =="
  while IFS=$'\t' read -r owner key; do
    echo "  ${PREFIX}/${owner}/${key}"
  done < "$PLACEHOLDER_FILE"
  echo
  echo "  These values cannot be randomly generated (external provider credentials)."
  echo "  Overwrite them with:"
  echo "    bao kv patch ${PREFIX}/<owner> <key>=<real-value>"
fi

echo
echo "Done. Point External Secrets Operator at ${PREFIX}/<owner>/<key>."
