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
    echo 0 ;;
  curl) cat "$CASE_DIR/response.json" ;;
  osascript)
    echo quit >> "$CASE_DIR/actions"
    [[ "$SCENARIO" != quit-error ]] ;;
  pgrep)
    [[ "$SCENARIO" != process-error ]] || exit 2
    [[ "$SCENARIO" != stop-timeout ]] || exit 0
    [[ -f "$CASE_DIR/started" && "$SCENARIO" != start-timeout ]] ;;
  open)
    echo open >> "$CASE_DIR/actions"
    touch "$CASE_DIR/started" ;;
  sleep) : ;;
esac
EOF
chmod +x "$TEST_TMP/bin/fake"
for command in sqlite3 curl osascript pgrep open sleep; do
  ln -s fake "$TEST_TMP/bin/$command"
done

failures=0
for scenario in db-error empty-catalog invalid-entry quit-error stop-timeout process-error start-timeout success; do
  case_dir="$TEST_TMP/$scenario"
  mkdir -p "$case_dir/codex" "$case_dir/switch"
  printf 'model = "test-model"\n' > "$case_dir/codex/config.toml"
  printf '{"apps":{"codex":{"proxy_route":"test-route"}}}\n' > "$case_dir/switch/live-state.json"
  touch "$case_dir/switch/cc-switch.db"
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
    SCENARIO="$scenario" CASE_DIR="$case_dir" \
    bash "$SCRIPT" > "$case_dir/output" 2>&1 || status=$?
  passed=true
  if [[ "$scenario" == success ]]; then
    [[ "$status" == 0 ]] || passed=false
    cmp -s "$case_dir/response.json" "$case_dir/codex/cc-switch-model-catalog.json" || passed=false
    grep -q 'Refresh complete' "$case_dir/output" || passed=false
    grep -q 'Catalog models: test-model, other-model' "$case_dir/output" || passed=false
  else
    [[ "$status" != 0 ]] || passed=false
    if grep -q 'Refresh complete' "$case_dir/output"; then passed=false; fi
    case "$scenario" in
      db-error|empty-catalog|invalid-entry)
        cmp -s "$case_dir/original.json" "$case_dir/codex/cc-switch-model-catalog.json" || passed=false
        [[ ! -f "$case_dir/actions" ]] || passed=false ;;
      quit-error|stop-timeout|process-error)
        [[ ! -f "$case_dir/started" ]] || passed=false ;;
    esac
  fi
  if "$passed"; then
    printf '[PASS] %s\n' "$scenario"
  else
    printf '[FAIL] %s (exit=%s)\n' "$scenario" "$status"
    cat "$case_dir/output"
    failures=$((failures + 1))
  fi
done
[[ "$failures" == 0 ]]
