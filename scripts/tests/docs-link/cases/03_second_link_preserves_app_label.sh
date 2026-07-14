#!/usr/bin/env bash
# 同一 target 再次 link 时保留已有 app_label；无 app_label 时默认 app_name
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../docs-install/test-lib.sh
source "$TEST_DIR/../../docs-install/test-lib.sh"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  pass "跳过（需 Bash 5+）"
  exit 0
fi

TMP_DIR="$(new_tmp_dir)"
ROOT_DIR="$(cd "$TEST_DIR/../../../.." && pwd)"
DOCS_LINK="$ROOT_DIR/scripts/docs-link.sh"
FAKEHOME="$TMP_DIR/fakehome"
SYS_SRC="$FAKEHOME/ws/system-kb"
APP_TGT="$FAKEHOME/ws/my-application-repo"
LIST="$SYS_SRC/docs/knowledge-links.yaml"
TPL="$ROOT_DIR/system/application-APPNAME"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

[[ -d "$TPL" ]] || fail "缺少模板目录: $TPL"

mkdir -p "$SYS_SRC/docs" "$APP_TGT/docs"
cp -R "$TPL" "$SYS_SRC/docs/application-APPNAME"
git -C "$SYS_SRC" init -q
git -C "$APP_TGT" init -q
git -C "$APP_TGT" remote add origin "https://example.com/org/my-application-repo.git"

cat >"$SYS_SRC/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$SYS_SRC
DOC_DIR=system
KNOWLEDGE_TYPE=system
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

cat >"$APP_TGT/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$APP_TGT
DOC_DIR=application
KNOWLEDGE_TYPE=application
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

run_link() {
  ( cd "$SYS_SRC" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --link --target "$APP_TGT" )
}

run_link || fail "首次 link 应成功"
assert_file_exists "$LIST"

# 将 app_label 改为与 app_name 不同，第二次 link 后应仍保留
if grep -q '^[[:space:]]*app_label:' "$LIST"; then
  if [[ "$(uname -s)" == 'Darwin' ]]; then
    sed -i '' 's/^\([[:space:]]*app_label:\).*/\1 "保留测签"/' "$LIST"
  else
    sed -i 's/^\([[:space:]]*app_label:\).*/\1 "保留测签"/' "$LIST"
  fi
else
  fail "首次 link 后应写出 app_label 行"
fi

run_link || fail "第二次 link 应成功"
grep -Fq 'app_label: "保留测签"' "$LIST" || fail "再次 link 应保留已有 app_label"

pass "再次 link 保留已有 app_label"
