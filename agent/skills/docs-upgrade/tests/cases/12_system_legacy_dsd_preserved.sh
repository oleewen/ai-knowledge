#!/usr/bin/env bash
# 元库移除系统 DSD 占位后，已有详设须归本库独有并原样保留。
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
SOURCE_ROOT="$(cd "$DOCS_UPGRADE_SKILL_DIR/../../.." && pwd)"
META_ROOT="$TMP_DIR/meta"
OUT_FILE="$TMP_DIR/output"
LEGACY_REL='requirements/REQUIREMENT-EXAMPLE/MVP-Phase-1/DSD-EXAMPLE-1.md'
mkdir -p "$(dirname "$DOCS_DIR/$LEGACY_REL")"
# 非 Git 模板快照用于测试当前工作树；Git 元库按设计只读取已提交的 HEAD。
mkdir -p "$META_ROOT"
cp -R "$SOURCE_ROOT/system" "$META_ROOT/system"
git -C "$PROJECT_DIR" init -q
cat >"$PROJECT_DIR/.docsconfig" <<EOF
REPO_DIR=project
DOC_DIR=docs
AGENT_ROOT=$TMP_DIR/agent-home
AGENT_DIR=.agents
KNOWLEDGE_TYPE=system
EOF
pin_workspace_for_repo "$PROJECT_DIR" "$TMP_DIR/agent-home" .agents
printf '%s\n' '# 既有系统详设' '' '已补充的实现细节，须保留原文。' >"$DOCS_DIR/$LEGACY_REL"
cp "$DOCS_DIR/$LEGACY_REL" "$TMP_DIR/original-dsd"

run_upgrade() {
  (cd "$PROJECT_DIR" && "$BASH" "$DOCS_UPGRADE_SCRIPT" --meta-path "$META_ROOT" "$@") >"$OUT_FILE" 2>&1 \
    || { cat "$OUT_FILE"; fail '系统升级命令失败'; }
}

run_upgrade --dry-run
awk '/^== 本库独有\(保留\) / { active=1; next } /^== / { active=0 } active' "$OUT_FILE" >"$TMP_DIR/local-only"
assert_contains " $LEGACY_REL" "$TMP_DIR/local-only"
cmp -s "$TMP_DIR/original-dsd" "$DOCS_DIR/$LEGACY_REL" || fail '预览不得改写历史 DSD'
assert_file_not_exists "$DOCS_DIR/DESIGN.md"

run_upgrade --apply-scaffold
cmp -s "$TMP_DIR/original-dsd" "$DOCS_DIR/$LEGACY_REL" || fail '升级不得删除或改写历史 DSD'
assert_file_exists "$DOCS_DIR/DESIGN.md"

pass '元库删除系统 DSD 占位后，升级预览与实际补骨架均保留已有详设'
