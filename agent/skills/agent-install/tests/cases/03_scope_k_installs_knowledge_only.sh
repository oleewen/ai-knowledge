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

run_agent_install "$FAKE_HOME" --scope=k >"$OUT_FILE" 2>&1

STORE="$FAKE_HOME/.agents"

assert_file_exists "$STORE/knowledge/naming-conventions.md"
assert_file_exists "$STORE/references/knowledge-layout.md"
assert_dir_not_exists "$STORE/rules"
assert_dir_not_exists "$STORE/skills"
assert_dir_not_exists "$STORE/scripts"

pass "scope=k 仅安装 knowledge/ 与 references/"
