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

run_agent_install "$FAKE_HOME" --scope=r >"$OUT_FILE" 2>&1

assert_dir_not_exists "$FAKE_HOME/.agents/knowledge"
assert_dir_not_exists "$FAKE_HOME/.agents/references"
assert_file_exists "$FAKE_HOME/.agents/rules/CONVENTIONS.md"

pass "scope=r 不安装 knowledge/ 与 references/"
