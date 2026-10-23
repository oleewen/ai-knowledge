#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
mkdir -p "$FAKE_HOME/workspaces/app" "$FAKE_HOME/workspaces/ai-knowledge"
printf 'keep\n' >"$FAKE_HOME/workspaces/ai-knowledge/local-note"
if run_docs_bootstrap "$FAKE_HOME" --components=both --agents=codex \
  --doc-target "$FAKE_HOME/workspaces/app/docs" >"$FAKE_HOME/out" 2>&1; then
  fail '已有元库目录时须停止'
fi
grep -q -- '请用 --meta PATH' "$FAKE_HOME/out" || fail "未报告元库冲突：$(tail -20 "$FAKE_HOME/out")"
assert_contains 'keep' "$FAKE_HOME/workspaces/ai-knowledge/local-note"
assert_dir_not_exists "$FAKE_HOME/.agents"
assert_file_not_exists "$FAKE_HOME/workspaces/app/.docsconfig"
pass "默认元库路径冲突时保留原目录，安装前停止"
