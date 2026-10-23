#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
mkdir -p "$FAKE_HOME/preexisting"
printf 'keep\n' >"$FAKE_HOME/preexisting/sentinel"
if (
  source <(sed '$d' "$DOCS_BOOTSTRAP_SCRIPT")
  HOME="$FAKE_HOME"
  GIT_REPO_URL="$ROOT_DIR"
  docsconfig_bootstrap_gen_clone_dir() { printf '%s' "$FAKE_HOME/preexisting"; }
  bs_main --components=agent --agents=codex
) >"$FAKE_HOME/out" 2>&1; then
  fail '临时目录冲突时应拒绝覆盖'
fi
assert_contains '拒绝覆盖' "$FAKE_HOME/out"
assert_contains 'keep' "$FAKE_HOME/preexisting/sentinel"
assert_dir_not_exists "$FAKE_HOME/.agents"
pass "临时目录冲突失败后不清理他人目录"
