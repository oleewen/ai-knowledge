#!/usr/bin/env bash

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Usage: refresh-codex.sh

Wait for Codex requests to become idle, refresh the CC Switch model catalog,
restart Codex, confirm its process starts, then verify route configuration.

Environment overrides:
  CODEX_HOME                       Codex config directory
  CC_SWITCH_HOME                   CC Switch data directory
  CC_SWITCH_PROXY_URL              Local proxy URL
  CODEX_REFRESH_MAX_WAIT_SECONDS   Idle wait limit, default 300
  CODEX_REFRESH_IDLE_SECONDS       Recent-request window, default 5
EOF
  exit 0
fi

codex_home="${CODEX_HOME:-$HOME/.codex}"
cc_switch_home="${CC_SWITCH_HOME:-$HOME/.cc-switch}"
config_file="$codex_home/config.toml"
catalog_file="$codex_home/cc-switch-model-catalog.json"
live_state_file="$cc_switch_home/live-state.json"
proxy_url="${CC_SWITCH_PROXY_URL:-http://127.0.0.1:15721}"
max_wait_seconds="${CODEX_REFRESH_MAX_WAIT_SECONDS:-300}"
idle_seconds="${CODEX_REFRESH_IDLE_SECONDS:-5}"

log() {
  printf '[refresh-codex] %s\n' "$*"
}

die() {
  printf '[refresh-codex] ERROR: %s\n' "$*" >&2
  exit 1
}

# pgrep: 1 means absent; other failures must not look like a stopped app.
codex_running() {
  local status=0
  pgrep -f '/Codex( |$)' >/dev/null 2>&1 || status=$?
  case "$status" in
    0) return 0 ;;
    1) return 1 ;;
    *) die "Cannot determine Codex process state (pgrep exit $status)" ;;
  esac
}

command -v curl >/dev/null 2>&1 || die "curl is required"
command -v jq >/dev/null 2>&1 || die "jq is required"
command -v osascript >/dev/null 2>&1 || die "osascript is required on macOS"
command -v open >/dev/null 2>&1 || die "open is required on macOS"
command -v pgrep >/dev/null 2>&1 || die "pgrep is required"

[[ -f "$config_file" ]] || die "Codex config not found: $config_file"
[[ -f "$live_state_file" ]] || die "CC Switch live state not found: $live_state_file"

model="$(sed -n 's/^model[[:space:]]*=[[:space:]]*"\([^"]*\)"/\1/p' "$config_file" | head -1)"
route_id="$(jq -r '.apps.codex.proxy_route // empty' "$live_state_file")"
[[ -n "$model" ]] || die "No model found in $config_file"
[[ -n "$route_id" ]] || die "No active Codex route found in $live_state_file"

log "Current model: $model"
log "Current CC Switch route: $route_id"

if command -v sqlite3 >/dev/null 2>&1 && [[ -f "$cc_switch_home/cc-switch.db" ]]; then
  deadline=$((SECONDS + max_wait_seconds))
  idle_count=0
  while (( SECONDS < deadline )); do
    recent_requests="$(sqlite3 "$cc_switch_home/cc-switch.db" \
      "select count(*) from proxy_request_logs where app_type='codex' and created_at >= strftime('%s','now') - $idle_seconds;")" \
      || die "Cannot determine Codex activity: database query failed"
    if [[ "$recent_requests" == "0" ]]; then
      idle_count=$((idle_count + 1))
      (( idle_count >= 2 )) && break
    else
      idle_count=0
      log "Codex request activity detected; waiting..."
    fi
    sleep 2
  done
  (( idle_count >= 2 )) || die "Codex did not become idle within ${max_wait_seconds}s"
else
  log "CC Switch database unavailable; skipping activity wait"
fi

temp_catalog="$(mktemp "${TMPDIR:-/tmp}/codex-model-catalog.XXXXXX")"
backup_catalog="${catalog_file}.backup.$(date +%Y%m%d-%H%M%S)"
trap 'rm -f "$temp_catalog"' EXIT

log "Refreshing model catalog from $proxy_url/v1/models"
curl -fsS --max-time 20 "$proxy_url/v1/models" > "$temp_catalog"
jq -e '.models | type == "array" and length > 0 and
  all(.[]; type == "object" and
    ((.slug // .id) | type == "string" and test("\\S")))' "$temp_catalog" >/dev/null \
  || die "Proxy returned an invalid model catalog"

if [[ -f "$catalog_file" ]]; then
  cp "$catalog_file" "$backup_catalog"
  log "Saved previous catalog: $backup_catalog"
fi
mv "$temp_catalog" "$catalog_file"
trap - EXIT

log "Stopping Codex"
osascript -e 'tell application id "com.openai.codex" to quit' >/dev/null \
  || die "Codex quit request failed"

for _ in {1..30}; do
  codex_running || break
  sleep 1
done
if codex_running; then
  die "Codex did not stop within 30s"
fi

log "Starting Codex"
open -b com.openai.codex >/dev/null

for _ in {1..30}; do
  codex_running && break
  sleep 1
done
codex_running || die "Codex process did not start within 30s"
new_model="$(sed -n 's/^model[[:space:]]*=[[:space:]]*"\([^"]*\)"/\1/p' "$config_file" | head -1)"
new_route_id="$(jq -r '.apps.codex.proxy_route // empty' "$live_state_file")"
catalog_models="$(jq -r '[.models[] | .slug // .id] | join(", ")' "$catalog_file")"

[[ "$new_model" == "$model" ]] || die "Model changed unexpectedly: $new_model"
[[ "$new_route_id" == "$route_id" ]] || die "Route changed unexpectedly: $new_route_id"
[[ -n "$catalog_models" ]] || die "Refreshed model catalog is empty"

log "Refresh complete"
log "Codex process detected; service readiness was not checked"
log "Model: $new_model"
log "Route: $new_route_id"
log "Catalog models: $catalog_models"
