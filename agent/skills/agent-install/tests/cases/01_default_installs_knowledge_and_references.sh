#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

FAKE_HOME="$(new_fake_home)"
OUT_FILE="$FAKE_HOME/out.txt"

cleanup() {
  rm -rf "$FAKE_HOME"
}
trap cleanup EXIT

run_agent_install "$FAKE_HOME" --scope=a >"$OUT_FILE" 2>&1

STORE="$FAKE_HOME/.agents"
CURSOR="$FAKE_HOME/.cursor"

assert_file_exists "$STORE/knowledge/glossary.md"
assert_file_exists "$STORE/references/session-spec-path.md"
assert_symlink_points_to "$CURSOR/knowledge" "$STORE/knowledge"
assert_symlink_points_to "$CURSOR/references" "$STORE/references"
assert_file_exists "$STORE/configs"
assert_contains "WORK_SPACE=" "$STORE/configs"
if [[ -e "$CURSOR/configs" || -L "$CURSOR/configs" ]]; then
  fail "链接 IDE 时不应带上 configs: $CURSOR/configs"
fi

pass "scope=a 安装 knowledge/ 与 references/ 并建立软链"
