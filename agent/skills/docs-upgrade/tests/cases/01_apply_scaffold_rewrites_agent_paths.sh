#!/usr/bin/env bash
# --apply-scaffold 收尾重写 agent/（同 docs-install）；dry-run 无副作用；空骨架桶亦扫全树
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
META_ROOT="$TMP_DIR/meta"
OUT_FILE="$TMP_DIR/case01.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR" "$META_ROOT/application"
git -C "$PROJECT_DIR" init -q

cat >"$PROJECT_DIR/.docsconfig" <<EOF
DOC_ROOT=$DOCS_DIR
REPO_ROOT=$PROJECT_DIR
DOC_DIR=docs
AGENT_ROOT=$PROJECT_DIR
AGENT_DIRS=".claude .cursor"
KNOWLEDGE_TYPE=application
EOF

# 元库：将 scaffold 的新文件含裸 agent/；README 供注记注入
cat >"$META_ROOT/application/README.md" <<'EOF'
# App docs

See agent/skills/docs-indexing for indexing.
EOF

cat >"$META_ROOT/application/scaffold-new.md" <<'EOF'
# New

Link: agent/skills/docs-upgrade
EOF

# 本库已有等值文件（使 ADD 可非空仅 scaffold-new）+ 本库独有残留 agent/
cat >"$DOCS_DIR/README.md" <<'EOF'
# App docs

See agent/skills/docs-indexing for indexing.
EOF

cat >"$DOCS_DIR/local-only.md" <<'EOF'
# Local

Still points to agent/skills/docs-install
EOF

# dry-run：不得改写路径
(
  cd "$PROJECT_DIR"
  bash "$DOCS_UPGRADE_SCRIPT" --dry-run --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)

assert_contains "agent/skills/docs-indexing" "$DOCS_DIR/README.md"
assert_contains "agent/skills/docs-install" "$DOCS_DIR/local-only.md"
assert_not_contains ".claude/skills" "$DOCS_DIR/README.md"
[[ ! -f "$DOCS_DIR/scaffold-new.md" ]] || fail "dry-run 不应写入 scaffold-new.md"

# apply-scaffold：写入新骨架 + 全树 rewrite（含本库独有）
(
  cd "$PROJECT_DIR"
  bash "$DOCS_UPGRADE_SCRIPT" --apply-scaffold --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)

assert_file_exists "$DOCS_DIR/scaffold-new.md"
assert_contains ".claude/skills/docs-upgrade" "$DOCS_DIR/scaffold-new.md"
assert_not_contains "agent/skills/docs-upgrade" "$DOCS_DIR/scaffold-new.md"

assert_contains ".claude/skills/docs-indexing" "$DOCS_DIR/README.md"
assert_not_contains "agent/skills/docs-indexing" "$DOCS_DIR/README.md"
assert_contains "<!-- sdx-agent-dirs-note:begin -->" "$DOCS_DIR/README.md"
assert_contains "其他可用 Agent 根目录" "$DOCS_DIR/README.md"
assert_contains ".cursor" "$DOCS_DIR/README.md"

assert_contains ".claude/skills/docs-install" "$DOCS_DIR/local-only.md"
assert_not_contains "agent/skills/docs-install" "$DOCS_DIR/local-only.md"

# 空骨架桶仍 rewrite：再跑一次（ADD 应为空），改回残留再验证扫全树
printf '%s\n' '# Local again' 'agent/skills/docs-tag' >"$DOCS_DIR/local-only.md"
(
  cd "$PROJECT_DIR"
  bash "$DOCS_UPGRADE_SCRIPT" --apply-scaffold --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)
assert_contains ".claude/skills/docs-tag" "$DOCS_DIR/local-only.md"
assert_not_contains "agent/skills/docs-tag" "$DOCS_DIR/local-only.md"

pass "apply-scaffold 收尾重写 agent/（含空桶）；dry-run 无副作用"
