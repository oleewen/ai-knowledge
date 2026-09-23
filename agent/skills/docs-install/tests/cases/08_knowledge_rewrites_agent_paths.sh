#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
ensure_test_agent_home "$TMP_DIR"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case08.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

cat >"$PROJECT_DIR/.docsconfig" <<EOF
DOC_ROOT=$DOCS_DIR
REPO_ROOT=$PROJECT_DIR
DOC_DIR=docs
AGENT_ROOT=~
AGENT_DIR=.agents
KNOWLEDGE_TYPE=application
EOF

bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target "$DOCS_DIR" >"$OUT_FILE" 2>&1

CHG_README="$DOCS_DIR/changelogs/README.md"
assert_file_exists "$CHG_README"
assert_contains "../.agents/skills/docs-indexing" "$CHG_README"
assert_not_contains "agent/skills/docs-indexing" "$CHG_README"
assert_not_contains "~/.agents/" "$CHG_README"

mkdir -p "$DOCS_DIR/sub/deep"
printf '%s\n' '../agent/knowledge/a.md' '../../agent/skills/b.md' '~/.agents/references/c.md' '.agents/knowledge/d.md' >"$DOCS_DIR/sub/deep/paths.md"
(
  source "$ROOT_DIR/agent/scripts/lib/rewrite.sh"
  rewrite_agent_path_segment_in_file "$DOCS_DIR/sub/deep/paths.md" "$DOCS_DIR" consumer
)
printf '%s\n' '../../.agents/knowledge/a.md' '../../.agents/skills/b.md' '../../.agents/references/c.md' '../../.agents/knowledge/d.md' >"$DOCS_DIR/expected-paths.md"
cmp -s "$DOCS_DIR/sub/deep/paths.md" "$DOCS_DIR/expected-paths.md" || {
  echo "got:" >&2
  cat "$DOCS_DIR/sub/deep/paths.md" >&2
  fail "深度相对 .agents/ 重写失败"
}

ROOT_README="$DOCS_DIR/README.md"
assert_file_exists "$ROOT_README"
assert_contains "<!-- sdx-agent-dirs-note:begin -->" "$ROOT_README"
assert_contains ".agents/" "$ROOT_README"
assert_not_contains "IDE 软链目录" "$ROOT_README"

[[ -L "$DOCS_DIR/.agents" ]] || fail "应存在 .agents 软链"

pass "knowledge 安装后将 agent/ 重写为深度相对 .agents/，建软链，并注入 README 注记"
