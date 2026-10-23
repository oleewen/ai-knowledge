#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
mkdir -p "$FAKE_HOME/workspaces/app"
# 从其他 cwd 以 stdin 加载，覆盖 curl | bash 无法预载共享库的入口。
(cd "$FAKE_HOME" && HOME="$FAKE_HOME" GIT_REPO_URL="$ROOT_DIR" "$BASH" -s -- \
  --components=both --agents=codex --doc-target "$FAKE_HOME/workspaces/app/docs" \
  <"$DOCS_BOOTSTRAP_SCRIPT") >"$FAKE_HOME/out" 2>&1 \
  || fail "管道入口失败：$(tail -20 "$FAKE_HOME/out")"
assert_file_exists "$FAKE_HOME/workspaces/app/docs/knowledge-links.yaml"
assert_dir_exists "$FAKE_HOME/workspaces/ai-knowledge/.git"
assert_contains '${WORK_SPACE}/ai-knowledge' "$FAKE_HOME/workspaces/app/docs/knowledge-links.yaml"
pass "管道入口可加载共享库并保留有效元库"
