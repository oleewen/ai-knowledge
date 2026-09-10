#!/usr/bin/env bash
# unlink 删除目标 links 中 type:parent；不改正文跨层 HTTP
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
COMPANY="$FAKEHOME/ws/company-repo"
SYSTEM="$FAKEHOME/ws/sys-foo"
STUB="$SYSTEM/docs/knowledge/business/BD-EXAMPLE.md"
HREF='https://github.com/example/company-ea/blob/main/docs/knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md'

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$COMPANY/docs" "$SYSTEM/docs"
git -C "$COMPANY" init -q
git -C "$SYSTEM" init -q
git -C "$COMPANY" remote add origin "https://github.com/example/company-ea.git"
git -C "$SYSTEM" remote add origin "https://example.com/org/sys-foo.git"

cp -R "$ROOT_DIR/company/system-slots" "$COMPANY/docs/system-slots"
printf '%s\n' 'links: []' >"$SYSTEM/docs/knowledge-links.yaml"

cat >"$COMPANY/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$COMPANY
DOC_DIR=docs
KNOWLEDGE_TYPE=company
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

cat >"$SYSTEM/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$SYSTEM
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

run_link() {
  ( cd "$COMPANY" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --link --target "$SYSTEM" )
}

run_unlink() {
  ( cd "$COMPANY" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --unlink --target "$SYSTEM" )
}

run_link || fail "docs-link --link 应成功"
grep -Fq 'type: parent' "$SYSTEM/docs/knowledge-links.yaml" \
  || fail "link 后目标应含 type: parent"
assert_file_exists "$COMPANY/docs/knowledge-links.yaml"
grep -Fq 'sys_name: "sys-foo"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "link 后清单应含 sys-foo"

mkdir -p "$(dirname "$STUB")"
cat >"$STUB" <<EOF
## 依据与证据

- 上游：[BD-EXAMPLE]($HREF)
- 其它：保留
EOF

run_unlink || fail "docs-link --unlink 应成功"

grep -Fq 'type: parent' "$SYSTEM/docs/knowledge-links.yaml" \
  && fail "unlink 后不应残留 type: parent"
grep -Fq "$HREF" "$STUB" || fail "unlink 不应改正文跨层 HTTP"

if grep -Fq 'sys_name: "sys-foo"' "$COMPANY/docs/knowledge-links.yaml"; then
  fail "源仓 child 登记应已移除"
fi

pass "unlink 删除目标 type:parent，且不改正文 HTTP"
