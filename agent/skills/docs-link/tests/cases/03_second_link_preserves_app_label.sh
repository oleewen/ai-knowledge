#!/usr/bin/env bash
# 同一 target 再次 link 时保留已有 label；无 label 时默认 name
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  pass "跳过（需 Bash 5+）"
  exit 0
fi

TMP_DIR="$(new_tmp_dir)"
ROOT_DIR="$(cd "$TEST_DIR/../../../../.." && pwd)"
DOCS_LINK="$ROOT_DIR/agent/skills/docs-link/scripts/docs-link.sh"
FAKEHOME="$TMP_DIR/fakehome"
SYS_SRC="$FAKEHOME/ws/system-kb"
APP_TGT="$FAKEHOME/ws/my-application-repo"
LIST="$SYS_SRC/docs/knowledge-links.yaml"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$SYS_SRC/docs/application-slots" "$APP_TGT/docs"
printf '%s\n' 'links: []' >"$APP_TGT/docs/knowledge-links.yaml"
git -C "$SYS_SRC" init -q
git -C "$APP_TGT" init -q
git -C "$SYS_SRC" remote add origin "https://example.com/org/system-kb.git"
git -C "$APP_TGT" remote add origin "https://example.com/org/my-application-repo.git"

cat >"$SYS_SRC/.docsconfig" <<EOF
REPO_DIR=$(basename "$SYS_SRC")
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$TMP_DIR
AGENT_DIR=agent
EOF
pin_workspace_for_repo "$SYS_SRC" "$TMP_DIR" agent

cat >"$APP_TGT/.docsconfig" <<EOF
REPO_DIR=$(basename "$APP_TGT")
DOC_DIR=docs
KNOWLEDGE_TYPE=application
AGENT_ROOT=$TMP_DIR
AGENT_DIR=agent
EOF
pin_workspace_for_repo "$APP_TGT" "$TMP_DIR" agent

run_link() {
  ( cd "$SYS_SRC" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --link --target "$APP_TGT" )
}

run_link || fail "首次 link 应成功"
assert_file_exists "$LIST"

# 将 label 改为与 name 不同，第二次 link 后应仍保留
if grep -q '^[[:space:]]*label:' "$LIST"; then
  if [[ "$(uname -s)" == 'Darwin' ]]; then
    sed -i '' 's/^\([[:space:]]*label:\).*/\1 "保留测签"/' "$LIST"
  else
    sed -i 's/^\([[:space:]]*label:\).*/\1 "保留测签"/' "$LIST"
  fi
else
  fail "首次 link 后应写出 label 行"
fi

run_link || fail "第二次 link 应成功"
grep -Fq 'label: "保留测签"' "$LIST" || fail "再次 link 应保留已有 label"
[[ -L "$SYS_SRC/docs/application-slots/application-my-application-repo" ]] \
  || fail "建联后槽位应为软链"
[[ ! -e "$SYS_SRC/docs/application-slots/changelogs" ]] \
  || fail "不应再创建 application-slots/changelogs"

pass "再次 link 保留已有 app_label"
