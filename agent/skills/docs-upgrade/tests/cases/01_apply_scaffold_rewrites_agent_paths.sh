#!/usr/bin/env bash
# --apply-scaffold 收尾重写 agent/ → ~/.agents/（同 docs-install）；dry-run 无副作用；空骨架桶亦扫全树
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
AGENT_ROOT=~/.agents
KNOWLEDGE_TYPE=application
EOF

cat >"$META_ROOT/application/README.md" <<'EOF'
# App docs

See agent/skills/docs-indexing for indexing.
EOF

cat >"$META_ROOT/application/scaffold-new.md" <<'EOF'
# New

Link: agent/skills/docs-upgrade
EOF

cat >"$DOCS_DIR/README.md" <<'EOF'
# App docs

See agent/skills/docs-indexing for indexing.
EOF

cat >"$DOCS_DIR/local-only.md" <<'EOF'
# Local

Still points to agent/skills/docs-install
Nested one: ../agent/knowledge/glossary.md
Nested two: ../../agent/skills/docs-indexing
Nested three: ../../../agent/references/knowledge-layout.md
Also old IDE: .claude/skills/docs-tag
EOF

(
  cd "$PROJECT_DIR"
  bash "$DOCS_UPGRADE_SCRIPT" --dry-run --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)

assert_contains "agent/skills/docs-indexing" "$DOCS_DIR/README.md"
assert_contains "agent/skills/docs-install" "$DOCS_DIR/local-only.md"
assert_contains ".claude/skills/docs-tag" "$DOCS_DIR/local-only.md"
assert_not_contains "~/.agents/skills" "$DOCS_DIR/README.md"
[[ ! -f "$DOCS_DIR/scaffold-new.md" ]] || fail "dry-run 不应写入 scaffold-new.md"

(
  cd "$PROJECT_DIR"
  bash "$DOCS_UPGRADE_SCRIPT" --apply-scaffold --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)

assert_file_exists "$DOCS_DIR/scaffold-new.md"
assert_contains "~/.agents/skills/docs-upgrade" "$DOCS_DIR/scaffold-new.md"
assert_not_contains "agent/skills/docs-upgrade" "$DOCS_DIR/scaffold-new.md"
assert_not_contains ".claude/skills/docs-upgrade" "$DOCS_DIR/scaffold-new.md"

assert_contains "~/.agents/skills/docs-indexing" "$DOCS_DIR/README.md"
assert_not_contains "agent/skills/docs-indexing" "$DOCS_DIR/README.md"
assert_contains "<!-- sdx-agent-dirs-note:begin -->" "$DOCS_DIR/README.md"
assert_contains "~/.agents/" "$DOCS_DIR/README.md"
assert_contains "IDE 软链目录" "$DOCS_DIR/README.md"

assert_contains "~/.agents/skills/docs-install" "$DOCS_DIR/local-only.md"
assert_contains "~/.agents/knowledge/glossary.md" "$DOCS_DIR/local-only.md"
assert_contains "~/.agents/skills/docs-indexing" "$DOCS_DIR/local-only.md"
assert_contains "~/.agents/references/knowledge-layout.md" "$DOCS_DIR/local-only.md"
assert_contains "~/.agents/skills/docs-tag" "$DOCS_DIR/local-only.md"
assert_not_contains "../agent/" "$DOCS_DIR/local-only.md"
assert_not_contains "../../agent/" "$DOCS_DIR/local-only.md"
assert_not_contains "../../../agent/" "$DOCS_DIR/local-only.md"
assert_not_contains "agent/skills/docs-install" "$DOCS_DIR/local-only.md"
assert_not_contains ".claude/skills/docs-tag" "$DOCS_DIR/local-only.md"

printf '%s\n' '# Local again' 'agent/skills/docs-tag' '.cursor/skills/docs-link' >"$DOCS_DIR/local-only.md"
(
  cd "$PROJECT_DIR"
  bash "$DOCS_UPGRADE_SCRIPT" --apply-scaffold --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)
assert_contains "~/.agents/skills/docs-tag" "$DOCS_DIR/local-only.md"
assert_contains "~/.agents/skills/docs-link" "$DOCS_DIR/local-only.md"
assert_not_contains "agent/skills/docs-tag" "$DOCS_DIR/local-only.md"
assert_not_contains ".cursor/skills/docs-link" "$DOCS_DIR/local-only.md"

pass "apply-scaffold 收尾重写 agent/ 与 IDE 段为 ~/.agents/（含空桶）；dry-run 无副作用"
