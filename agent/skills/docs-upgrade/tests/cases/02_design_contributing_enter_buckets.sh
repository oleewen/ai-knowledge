#!/usr/bin/env bash
# 根级 DESIGN.md 本无 scaffold、已改进整文件覆盖；links / README-s 仍排除
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
ensure_test_agent_home "$TMP_DIR"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
META_ROOT="$TMP_DIR/meta"
OUT_FILE="$TMP_DIR/case02.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR" "$META_ROOT/application"
git -C "$PROJECT_DIR" init -q

cat >"$PROJECT_DIR/.docsconfig" <<EOF
REPO_DIR=$(basename "$PROJECT_DIR")
DOC_DIR=docs
AGENT_ROOT=~
AGENT_DIR=.agents
KNOWLEDGE_TYPE=application
EOF
pin_workspace_for_repo "$PROJECT_DIR" "$HOME" .agents

cat >"$META_ROOT/application/DESIGN.md" <<'EOF'
# App Design

## 阅读顺序
meta design
EOF

cat >"$META_ROOT/application/knowledge-links.yaml" <<'EOF'
links: []
EOF

cat >"$META_ROOT/application/README-s.md" <<'EOF'
# App docs mapped
EOF

(
  cd "$PROJECT_DIR"
  "${BASH:-$(command -v bash)}" "$DOCS_UPGRADE_SCRIPT" --dry-run --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)

assert_contains " DESIGN.md" "$OUT_FILE"
assert_contains "== 新增骨架" "$OUT_FILE"
assert_not_contains " knowledge-links.yaml" "$OUT_FILE"
assert_not_contains " README-s.md" "$OUT_FILE"
[[ ! -f "$DOCS_DIR/DESIGN.md" ]] || fail "dry-run 不应写入 DESIGN.md"
[[ ! -f "$DOCS_DIR/README-s.md" ]] || fail "dry-run 不应写入 README-s.md"

(
  cd "$PROJECT_DIR"
  "${BASH:-$(command -v bash)}" "$DOCS_UPGRADE_SCRIPT" --apply-scaffold --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)

assert_file_exists "$DOCS_DIR/DESIGN.md"
assert_file_not_exists "$DOCS_DIR/knowledge-links.yaml"
assert_file_not_exists "$DOCS_DIR/README-s.md"
assert_contains "meta design" "$DOCS_DIR/DESIGN.md"

printf '%s\n' '# Local Design' '' '## 阅读顺序' 'local design body' >"$DOCS_DIR/DESIGN.md"
(
  cd "$PROJECT_DIR"
  "${BASH:-$(command -v bash)}" "$DOCS_UPGRADE_SCRIPT" --dry-run --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)
assert_contains " DESIGN.md" "$OUT_FILE"
assert_contains "== 整文件覆盖" "$OUT_FILE"

(
  cd "$PROJECT_DIR"
  "${BASH:-$(command -v bash)}" "$DOCS_UPGRADE_SCRIPT" --apply-scaffold --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)
assert_contains "meta design" "$DOCS_DIR/DESIGN.md"
assert_not_contains "local design body" "$DOCS_DIR/DESIGN.md"

pass "DESIGN 进骨架/整文件覆盖；links 与 README-s.md 仍排除"
