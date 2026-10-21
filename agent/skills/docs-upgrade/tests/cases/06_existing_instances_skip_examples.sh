#!/usr/bin/env bash
# 整树只跳过已有同目录真实实例的缺失示例；dry-run 与 apply 使用相同判定。
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
META_ROOT="$TMP_DIR/meta"
OUT_FILE="$TMP_DIR/output"
mkdir -p "$DOCS_DIR" "$META_ROOT/company"
git -C "$PROJECT_DIR" init -q
cat >"$PROJECT_DIR/.docsconfig" <<EOF
REPO_DIR=project
DOC_DIR=docs
AGENT_ROOT=$TMP_DIR/agent-home
AGENT_DIR=.agents
KNOWLEDGE_TYPE=company
EOF
pin_workspace_for_repo "$PROJECT_DIR" "$TMP_DIR/agent-home" .agents

write_fixture() {
  local root="$1" rel="$2" body="$3"
  mkdir -p "$(dirname "$root/$rel")"
  printf '%s\n' "$body" >"$root/$rel"
}

# 文件、示例目录、嵌套示例目录；目录里的普通文件也不补入。
SKIPPED=(
  knowledge/business/BL/BL-EXAMPLE.md
  knowledge/business/BD/BD-EXAMPLE/BD-EXAMPLE.md
  knowledge/business/BD/BD-EXAMPLE/index.md
  knowledge/business/BD/BD-EXAMPLE/BSD-EXAMPLE/README.md
  knowledge/business/BD/BD-EXAMPLE/diagram.svg
  knowledge/business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/index.md
  'analysis with spaces/ANALYSIS-EXAMPLE.md'
)
for rel in "${SKIPPED[@]}"; do
  write_fixture "$META_ROOT/company" "$rel" '# Example'
done
write_fixture "$DOCS_DIR" knowledge/business/BL/BL-RETAIL.md '# Real BL'
write_fixture "$DOCS_DIR" knowledge/business/BD/BD-SALES/BD-SALES.md '# Real BD'
write_fixture "$DOCS_DIR" knowledge/business/BSD-EXAMPLE-L2/BSD-ORDERS-L3/BSD-ORDERS-L3.md '# Real BSD'
write_fixture "$DOCS_DIR" 'analysis with spaces/ANALYSIS-实际业务.md' '# Real analysis'

# EXAMPLE 已存在的文件仍按原逻辑分类；新规则不删除、不遮蔽已改文件。
write_fixture "$META_ROOT/company" knowledge/business/BD/BD-EXAMPLE/existing.md '# Meta existing'
write_fixture "$DOCS_DIR" knowledge/business/BD/BD-EXAMPLE/existing.md '# Local existing'
write_fixture "$META_ROOT/company" knowledge/business/BL/BL-EXAMPLE-OLD.md '# Meta example'
write_fixture "$DOCS_DIR" knowledge/business/BL/BL-EXAMPLE-OLD.md '# Local example'

# 无真实实例、只在其他目录或子目录有实例、只有示例/软链/空目录，均须补骨架。
ADDED=(
  DESIGN.md
  knowledge/business/BL/README.md
  knowledge/business/BL/BL-POLICY.md
  knowledge/business/BL/BL-EXAMPLES.md
  knowledge/business/BD/index.md
  knowledge/business/BD/BD-EXAMPLEISH/index.md
  other/BL/BL-EXAMPLE.md
  nested/BL/BL-EXAMPLE.md
  examples-only/BL-EXAMPLE.md
  symlink-file/BL-EXAMPLE.md
  symlink-dir/BD-EXAMPLE/index.md
  symlink-entity/BD-EXAMPLE/index.md
  empty-dir/BD-EXAMPLE/index.md
  wrong-entity/BD-EXAMPLE/index.md
  examples-only-dir/BD-EXAMPLE/index.md
  no-instance/BD-EXAMPLE/index.md
)
for rel in "${ADDED[@]}"; do
  write_fixture "$META_ROOT/company" "$rel" '# Required scaffold'
done
write_fixture "$DOCS_DIR" nested/BL/subdir/BL-REAL.md '# Nested real BL'
write_fixture "$DOCS_DIR" examples-only/BL-EXAMPLE-OTHER.md '# Another example'
write_fixture "$DOCS_DIR" examples-only-dir/BD-EXAMPLE-OTHER/BD-EXAMPLE-OTHER.md '# Another example'
write_fixture "$DOCS_DIR" wrong-entity/BD-REAL/README.md '# Not an entity file'
mkdir -p "$DOCS_DIR/symlink-file" "$DOCS_DIR/symlink-dir" "$DOCS_DIR/symlink-entity/BD-REAL" "$DOCS_DIR/empty-dir/BD-REAL"
ln -s "$DOCS_DIR/knowledge/business/BL/BL-RETAIL.md" "$DOCS_DIR/symlink-file/BL-LINK.md"
ln -s "$TMP_DIR/missing.md" "$DOCS_DIR/symlink-file/BL-BROKEN.md"
ln -s "$DOCS_DIR/knowledge/business/BD/BD-SALES" "$DOCS_DIR/symlink-dir/BD-LINK"
ln -s "$DOCS_DIR/knowledge/business/BD/BD-SALES/BD-SALES.md" "$DOCS_DIR/symlink-entity/BD-REAL/BD-REAL.md"

run_upgrade() {
  (cd "$PROJECT_DIR" && "$BASH" "$DOCS_UPGRADE_SCRIPT" --meta-path "$META_ROOT" "$@") >"$OUT_FILE" 2>&1 \
    || { cat "$OUT_FILE"; fail '升级命令失败'; }
}

run_upgrade --dry-run
awk '/^== 新增骨架 / { active=1; next } /^== / { active=0 } active' "$OUT_FILE" >"$TMP_DIR/added"
awk '/^== 跳过 / { active=1; next } /^== / { active=0 } active' "$OUT_FILE" >"$TMP_DIR/skipped"
awk '/^== 结构重填 / { active=1; next } /^== / { active=0 } active' "$OUT_FILE" >"$TMP_DIR/refill"
for rel in "${SKIPPED[@]}"; do
  assert_not_contains " $rel" "$TMP_DIR/added"
  assert_contains " $rel (同类实例已存在:" "$TMP_DIR/skipped"
  assert_file_not_exists "$DOCS_DIR/$rel"
done
assert_contains 'knowledge/business/BL/BL-RETAIL.md' "$TMP_DIR/skipped"
assert_contains 'knowledge/business/BD/BD-SALES/BD-SALES.md' "$TMP_DIR/skipped"
for rel in "${ADDED[@]}"; do
  assert_contains " $rel" "$TMP_DIR/added"
  assert_file_not_exists "$DOCS_DIR/$rel"
done
assert_contains 'knowledge/business/BD/BD-EXAMPLE/existing.md' "$TMP_DIR/refill"
assert_contains 'knowledge/business/BL/BL-EXAMPLE-OLD.md' "$TMP_DIR/refill"
assert_dir_not_exists "$PROJECT_DIR/.docs-init"
[[ ! -L "$DOCS_DIR/.agents" ]] || fail 'dry-run 不应建软链'

run_upgrade --apply-scaffold
for rel in "${SKIPPED[@]}"; do
  assert_file_not_exists "$DOCS_DIR/$rel"
done
for rel in "${ADDED[@]}"; do
  assert_file_exists "$DOCS_DIR/$rel"
done
assert_dir_not_exists "$DOCS_DIR/knowledge/business/BD/BD-EXAMPLE/BSD-EXAMPLE"
assert_contains '# Local existing' "$DOCS_DIR/knowledge/business/BD/BD-EXAMPLE/existing.md"
assert_contains '# Local example' "$DOCS_DIR/knowledge/business/BL/BL-EXAMPLE-OLD.md"
assert_contains '# Real BL' "$DOCS_DIR/knowledge/business/BL/BL-RETAIL.md"
assert_contains '# Real BD' "$DOCS_DIR/knowledge/business/BD/BD-SALES/BD-SALES.md"

pass '整树按同目录真实实例跳过缺失示例，保留基础文件、已有文件及无实例示例'
