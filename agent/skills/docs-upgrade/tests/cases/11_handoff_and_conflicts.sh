#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
PROJECT="$TMP_DIR/project"
META="$TMP_DIR/meta"
mkdir -p "$PROJECT/docs" "$META/application"
git -C "$PROJECT" init -q
cat > "$PROJECT/.docsconfig" <<CONFIG
REPO_DIR=project
DOC_DIR=docs
AGENT_ROOT=$TMP_DIR/agent-home
AGENT_DIR=.agents
KNOWLEDGE_TYPE=application
CONFIG
pin_workspace_for_repo "$PROJECT" "$TMP_DIR/agent-home"
printf '# Template\n\n## New section\n' > "$META/application/topic.md"
printf '# Business\n\n## Existing\nKeep this body.\n' > "$PROJECT/docs/topic.md"
cp "$PROJECT/docs/topic.md" "$TMP_DIR/original"
run_upgrade() {
  (cd "$PROJECT" && "$BASH" "$DOCS_UPGRADE_SCRIPT" --meta-path "$META" "$@") > "$TMP_DIR/output" 2>&1
}
run_upgrade --dry-run
assert_dir_not_exists "$PROJECT/.docs-init"
run_upgrade --apply-scaffold
handoff="$(sed -n 's/^.*重填交接: //p' "$TMP_DIR/output")"
[[ -d "$handoff/templates" ]] || fail '退出后须保留重填模板'
cmp -s "$META/application/topic.md" "$handoff/templates/topic.md" || fail '快照不匹配'
assert_contains 'revision=unversioned' "$handoff/source.txt"
printf '# Later source\n' > "$META/application/topic.md"
assert_contains 'New section' "$handoff/templates/topic.md"
cmp -s "$TMP_DIR/original" "$PROJECT/docs/topic.md" || fail 'scaffold 不得重填业务正文'
for collision in directory parent; do
  case "$collision" in
    directory) mkdir -p "$PROJECT/docs/collision.md"; printf 'preserve\n' > "$PROJECT/docs/collision.md/local.txt"; printf '# Collision\n' > "$META/application/collision.md" ;;
    parent) printf 'keep parent\n' > "$PROJECT/docs/blocked"; mkdir -p "$META/application/blocked"; printf '# Child\n' > "$META/application/blocked/child.md" ;;
  esac
  for mode in --dry-run --apply-scaffold; do
    if run_upgrade "$mode"; then fail '路径类型冲突必须失败'; fi
    assert_contains '路径类型冲突' "$TMP_DIR/output"
    if [[ "$collision" == parent ]]; then
      assert_contains ' blocked/child.md' "$TMP_DIR/output"
    fi
    assert_not_contains '备份根:' "$TMP_DIR/output"
    cmp -s "$TMP_DIR/original" "$PROJECT/docs/topic.md" || fail '冲突不得写入正文'
    assert_contains 'preserve' "$PROJECT/docs/collision.md/local.txt"
  done
done
pass '快照交接持久且独立；目录及父路径类型冲突写入前拒绝'
