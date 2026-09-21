#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
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
AGENT_ROOT=$PROJECT_DIR
KNOWLEDGE_TYPE=application
EOF

bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target "$DOCS_DIR" >"$OUT_FILE" 2>&1

CHG_README="$DOCS_DIR/changelogs/README.md"
assert_file_exists "$CHG_README"
assert_contains "~/.agents/skills/docs-indexing" "$CHG_README"
assert_not_contains "agent/skills/docs-indexing" "$CHG_README"
assert_not_contains ".claude/skills/docs-indexing" "$CHG_README"

printf '%s\n' '../agent/knowledge/a.md' '../../agent/skills/b.md' '../../../agent/references/c.md' >"$DOCS_DIR/paths.md"
(
  cd "$DOCS_DIR"
  source "$ROOT_DIR/agent/scripts/lib/rewrite.sh"
  rewrite_agent_path_segment_in_tree "$DOCS_DIR"
)
printf '%s\n' '~/.agents/knowledge/a.md' '~/.agents/skills/b.md' '~/.agents/references/c.md' >"$DOCS_DIR/expected-paths.md"
cmp -s "$DOCS_DIR/paths.md" "$DOCS_DIR/expected-paths.md" || fail "多层 ../agent/ 未全部重写为 ~/.agents/"

ROOT_README="$DOCS_DIR/README.md"
assert_file_exists "$ROOT_README"
assert_contains "<!-- sdx-agent-dirs-note:begin -->" "$ROOT_README"
assert_contains "~/.agents/" "$ROOT_README"
assert_contains "IDE 软链目录" "$ROOT_README"
assert_contains ".cursor" "$ROOT_README"

pass "knowledge 安装后将 agent/ 重写为 ~/.agents/，并注入 README Agent 路径注记"
