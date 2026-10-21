#!/usr/bin/env bash
# 保持分类行为：规范化比较、非 md 本库胜、普通 changelog、排除与软链。
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
META_ROOT="$TMP_DIR/meta"
OUT_FILE="$TMP_DIR/output"
mkdir -p "$DOCS_DIR/application-slots/changelogs" "$META_ROOT/application/application-slots/changelogs" "$TMP_DIR/external"
git -C "$PROJECT_DIR" init -q
cat >"$PROJECT_DIR/.docsconfig" <<EOF
REPO_DIR=project
DOC_DIR=docs
AGENT_ROOT=$TMP_DIR/agent-home
AGENT_DIR=.agents
KNOWLEDGE_TYPE=application
EOF
pin_workspace_for_repo "$PROJECT_DIR" "$TMP_DIR/agent-home" .agents

printf '# Equal\r\n\r\n## Section\r\nSame body  \r\n' >"$DOCS_DIR/equal.md"
printf '# Equal\n\n## Section\nSame body\n' >"$META_ROOT/application/equal.md"
cp "$DOCS_DIR/equal.md" "$TMP_DIR/equal-original"
printf '%s\n' 'value: local' >"$DOCS_DIR/settings.yaml"
printf '%s\n' 'value: meta' >"$META_ROOT/application/settings.yaml"
printf '%s\n' '# Keep local-only' >"$DOCS_DIR/local-only.md"
printf '%s\n' '# History' '## Change' 'local history' >"$DOCS_DIR/application-slots/changelogs/history.md"
printf '%s\n' '# History' '## Change' 'meta history' >"$META_ROOT/application/application-slots/changelogs/history.md"
printf '%s\n' '# New history' >"$META_ROOT/application/application-slots/changelogs/new.md"
printf '%s\n' 'links: []' >"$META_ROOT/application/knowledge-links.yaml"
printf '%s\n' '# Must not appear' >"$META_ROOT/application/README-c.md"

mkdir -p "$META_ROOT/application/application-legacy" "$META_ROOT/application/protected"
printf '%s\n' '# Legacy ignored' >"$META_ROOT/application/application-legacy/new.md"
printf '%s\n' '# Protected scaffold' >"$META_ROOT/application/protected/new.md"
printf '%s\n' '# External original' >"$TMP_DIR/external/existing.md"
cp "$TMP_DIR/external/existing.md" "$TMP_DIR/external-original"
ln -s "$TMP_DIR/external" "$DOCS_DIR/protected"
ln -s "$TMP_DIR/external/existing.md" "$DOCS_DIR/linked.md"
printf '%s\n' '# Linked meta' >"$META_ROOT/application/linked.md"

run_upgrade() {
  (cd "$PROJECT_DIR" && "$BASH" "$DOCS_UPGRADE_SCRIPT" --meta-path "$META_ROOT" "$@") >"$OUT_FILE" 2>&1 \
    || { cat "$OUT_FILE"; fail '升级命令失败'; }
}

bucket() {
  local title="$1" output="$2"
  awk -v title="$title" 'index($0, "== " title " (") == 1 { active=1; next } /^== / { active=0 } active' "$OUT_FILE" >"$output"
}

run_upgrade --dry-run
bucket '跳过' "$TMP_DIR/skip"
bucket '结构重填' "$TMP_DIR/refill"
bucket '新增骨架' "$TMP_DIR/add"
bucket '本库独有(保留)' "$TMP_DIR/local"
bucket '跳过软链' "$TMP_DIR/symlinks"
bucket '忽略遗留槽位' "$TMP_DIR/legacy"
assert_contains ' equal.md' "$TMP_DIR/skip"
assert_contains ' settings.yaml (非 md 已改·本库胜)' "$TMP_DIR/skip"
assert_contains ' application-slots/changelogs/history.md' "$TMP_DIR/refill"
assert_contains ' application-slots/changelogs/new.md' "$TMP_DIR/add"
assert_contains ' local-only.md' "$TMP_DIR/local"
assert_contains ' linked.md' "$TMP_DIR/symlinks"
assert_contains ' protected' "$TMP_DIR/symlinks"
assert_contains ' application-legacy' "$TMP_DIR/legacy"
assert_not_contains 'knowledge-links.yaml' "$TMP_DIR/add"
assert_not_contains 'README-c.md' "$TMP_DIR/add"
assert_not_contains 'protected/new.md' "$TMP_DIR/add"
assert_not_contains 'application-legacy/new.md' "$TMP_DIR/add"
assert_dir_not_exists "$PROJECT_DIR/.docs-init"

run_upgrade --apply-scaffold
cmp -s "$TMP_DIR/equal-original" "$DOCS_DIR/equal.md" || fail '规范化相等文件须保留原字节'
assert_contains 'value: local' "$DOCS_DIR/settings.yaml"
assert_contains '# Keep local-only' "$DOCS_DIR/local-only.md"
assert_contains 'local history' "$DOCS_DIR/application-slots/changelogs/history.md"
cmp -s "$META_ROOT/application/application-slots/changelogs/new.md" "$DOCS_DIR/application-slots/changelogs/new.md" || fail '缺失 changelog 应作为普通骨架复制'
assert_file_not_exists "$DOCS_DIR/knowledge-links.yaml"
assert_file_not_exists "$DOCS_DIR/README-c.md"
assert_dir_not_exists "$DOCS_DIR/application-legacy"
assert_file_not_exists "$TMP_DIR/external/new.md"
cmp -s "$TMP_DIR/external-original" "$TMP_DIR/external/existing.md" || fail '不得改软链外部目标'
[[ -L "$DOCS_DIR/protected" && -L "$DOCS_DIR/linked.md" ]] || fail '软链须保留'

pass '扫描分类保留规范化/非 md/普通 changelog 行为，并保护排除项与软链'
