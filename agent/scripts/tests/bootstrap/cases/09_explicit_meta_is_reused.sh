#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
mkdir -p "$FAKE_HOME/workspaces/app"
META="$FAKE_HOME/workspaces/existing-meta"
git clone --quiet --local "$ROOT_DIR" "$META"
printf 'keep\n' >"$META/local-note"
BEFORE="$(git -C "$META" rev-parse HEAD)"
# 无效远端证明 --meta 路径不会再次克隆。
HOME="$FAKE_HOME" GIT_REPO_URL='/not-a-repository' "$BASH" "$DOCS_BOOTSTRAP_SCRIPT" \
  --components=both --meta "$META" --doc-target "$FAKE_HOME/workspaces/app/docs" \
  --agents=codex >"$FAKE_HOME/out" 2>&1 || fail "复用元库失败：$(tail -20 "$FAKE_HOME/out")"
assert_file_exists "$FAKE_HOME/workspaces/app/.docsconfig"
assert_contains '${WORK_SPACE}/existing-meta' "$FAKE_HOME/workspaces/app/docs/knowledge-links.yaml"
assert_contains 'keep' "$META/local-note"
[[ "$(git -C "$META" rev-parse HEAD)" == "$BEFORE" ]] || fail '复用元库不应改 HEAD'
assert_dir_not_exists "$FAKE_HOME/workspaces/ai-knowledge"
# docs-only 同样复用元库，不重装 Agent；config 仅重写配置。
mkdir -p "$FAKE_HOME/workspaces/second"
SCOPE=config HOME="$FAKE_HOME" GIT_REPO_URL='/not-a-repository' "$BASH" "$DOCS_BOOTSTRAP_SCRIPT" \
  --components=docs --meta="$META" --doc-target "$FAKE_HOME/workspaces/second/docs" \
  >"$FAKE_HOME/docs-out" 2>&1 || fail "docs-only 复用失败：$(tail -20 "$FAKE_HOME/docs-out")"
assert_file_exists "$FAKE_HOME/workspaces/second/.docsconfig"
assert_not_contains '执行 agent-install' "$FAKE_HOME/docs-out"
assert_file_exists "$META/local-note"
pass "显式元库不克隆、不清理、不改 HEAD，单选 docs 不装 Agent"
