#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/refresh-codex.sh"
TEST_TMP="$(mktemp -d)"
trap 'rm -rf "$TEST_TMP"' EXIT
mkdir -p "$TEST_TMP/bin"
cat > "$TEST_TMP/bin/fake" <<'EOF'
#!/usr/bin/env bash
set -eu
case "${0##*/}" in
  sqlite3)
    [[ "$SCENARIO" != db-error ]] || { echo 'database is locked' >&2; exit 1; }
    echo query >> "$CASE_DIR/sqlite.calls"
    echo 0 ;;
  curl)
    [[ "$SCENARIO" != curl-error ]] || { echo 'proxy unavailable' >&2; exit 22; }
    cat "$CASE_DIR/response.json" ;;
  cp)
    if [[ "$SCENARIO" == backup-error && "${2:-}" == *.backup.* ]]; then
      echo 'catalog backup failed' >&2
      exit 1
    fi
    exec "$REAL_CP" "$@" ;;
  osascript)
    echo quit >> "$CASE_DIR/actions"
    [[ "$SCENARIO" != quit-error ]] ;;
  pgrep)
    [[ "$SCENARIO" != process-error ]] || exit 2
    [[ "$SCENARIO" != stop-timeout ]] || exit 0
    [[ -f "$CASE_DIR/started" && "$SCENARIO" != start-timeout ]] ;;
  open)
    echo open >> "$CASE_DIR/actions"
    touch "$CASE_DIR/started"
    case "$SCENARIO" in
      model-changed) printf 'model = "changed-model"\n' > "$CODEX_HOME/config.toml" ;;
      route-changed) printf '{"apps":{"codex":{"proxy_route":"changed-route"}}}\n' > "$CC_SWITCH_HOME/live-state.json" ;;
    esac ;;
  sleep) : ;;
  *) echo "Unexpected fake command: ${0##*/}" >&2; exit 127 ;;
esac
EOF
chmod +x "$TEST_TMP/bin/fake"
for command in sqlite3 curl cp osascript pgrep open sleep; do
  ln -s fake "$TEST_TMP/bin/$command"
done

failures=0
for scenario in no-db db-error curl-error empty-catalog invalid-entry backup-error quit-error stop-timeout process-error start-timeout model-changed route-changed success; do
  case_dir="$TEST_TMP/$scenario"
  mkdir -p "$case_dir/codex" "$case_dir/switch"
  printf 'model = "test-model"\n' > "$case_dir/codex/config.toml"
  printf '{"apps":{"codex":{"proxy_route":"test-route"}}}\n' > "$case_dir/switch/live-state.json"
  [[ "$scenario" == no-db ]] || touch "$case_dir/switch/cc-switch.db"
  printf '{"models":[{"slug":"old-model"}]}\n' > "$case_dir/codex/cc-switch-model-catalog.json"
  cp "$case_dir/codex/cc-switch-model-catalog.json" "$case_dir/original.json"
  case "$scenario" in
    empty-catalog) printf '{"models":[]}\n' ;;
    invalid-entry) printf '{"models":[{"slug":42}]}\n' ;;
    *) printf '{"models":[{"slug":"test-model"},{"id":"other-model"}]}\n' ;;
  esac > "$case_dir/response.json"
  status=0
  env PATH="$TEST_TMP/bin:$PATH" CODEX_HOME="$case_dir/codex" \
    CC_SWITCH_HOME="$case_dir/switch" TMPDIR="$case_dir" \
    SCENARIO="$scenario" CASE_DIR="$case_dir" REAL_CP="$(command -v cp)" \
    bash "$SCRIPT" > "$case_dir/output" 2>&1 || status=$?
  passed=true
  if [[ "$scenario" == success || "$scenario" == no-db ]]; then
    [[ "$status" == 0 ]] || passed=false
    cmp -s "$case_dir/response.json" "$case_dir/codex/cc-switch-model-catalog.json" || passed=false
    grep -q 'Refresh complete' "$case_dir/output" || passed=false
    grep -q 'Catalog models: test-model, other-model' "$case_dir/output" || passed=false
  else
    [[ "$status" != 0 ]] || passed=false
    if grep -q 'Refresh complete' "$case_dir/output"; then passed=false; fi
    case "$scenario" in
      db-error|curl-error|empty-catalog|invalid-entry|backup-error)
        cmp -s "$case_dir/original.json" "$case_dir/codex/cc-switch-model-catalog.json" || passed=false
        [[ ! -f "$case_dir/actions" ]] || passed=false ;;
      quit-error|stop-timeout|process-error)
        [[ ! -f "$case_dir/started" ]] || passed=false ;;
    esac
  fi
  # Failure phases distinguish an unpublished catalog from a failed restart after publish.
  case "$scenario" in
    db-error|curl-error|empty-catalog|invalid-entry|backup-error)
      [[ ! -e "$case_dir/actions" ]] || passed=false ;;
    quit-error|stop-timeout|process-error)
      [[ "$(cat "$case_dir/actions")" == quit ]] || passed=false ;;
    *) [[ "$(cat "$case_dir/actions")" == $'quit\nopen' ]] || passed=false ;;
  esac
  case "$scenario" in
    no-db)
      grep -q 'database unavailable; skipping activity wait' "$case_dir/output" || passed=false
      [[ ! -e "$case_dir/sqlite.calls" ]] || passed=false ;;
    curl-error) grep -q 'proxy unavailable' "$case_dir/output" || passed=false ;;
    backup-error) grep -q 'catalog backup failed' "$case_dir/output" || passed=false ;;
    model-changed) grep -q 'Model changed unexpectedly: changed-model' "$case_dir/output" || passed=false ;;
    route-changed) grep -q 'Route changed unexpectedly: changed-route' "$case_dir/output" || passed=false ;;
  esac
  shopt -s nullglob
  leftover_catalogs=("$case_dir"/codex-model-catalog.*)
  backups=("$case_dir/codex"/*.backup.*)
  shopt -u nullglob
  [[ "${#leftover_catalogs[@]}" == 0 ]] || passed=false
  case "$scenario" in
    db-error|curl-error|empty-catalog|invalid-entry|backup-error)
      [[ "${#backups[@]}" == 0 ]] || passed=false ;;
    *)
      [[ "${#backups[@]}" == 1 ]] || passed=false
      [[ "${#backups[@]}" != 1 ]] || cmp -s "$case_dir/original.json" "${backups[0]}" || passed=false
      cmp -s "$case_dir/response.json" "$case_dir/codex/cc-switch-model-catalog.json" || passed=false ;;
  esac
  if "$passed"; then
    printf '[PASS] %s\n' "$scenario"
  else
    printf '[FAIL] %s (exit=%s)\n' "$scenario" "$status"
    cat "$case_dir/output"
    failures=$((failures + 1))
  fi
done
[[ "$failures" == 0 ]]
