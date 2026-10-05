#!/usr/bin/env bash
# unlink 删除目标 links 中 type:parent；不改正文跨层 HTTP（company → solution）
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../../docs-install/tests/test-lib.sh
source "$TEST_DIR/../../../docs-install/tests/test-lib.sh"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  pass "跳过（需 Bash 5+）"
  exit 0
fi

TMP_DIR="$(new_tmp_dir)"
ROOT_DIR="$(cd "$TEST_DIR/../../../../.." && pwd)"
DOCS_LINK="$ROOT_DIR/agent/skills/docs-link/scripts/docs-link.sh"
FAKEHOME="$TMP_DIR/fakehome"
COMPANY="$FAKEHOME/ws/company-repo"
SOLUTION="$FAKEHOME/ws/sln-foo"
STUB="$SOLUTION/docs/knowledge/business/BD-EXAMPLE.md"
HREF='https://github.com/example/company-ea/blob/main/docs/knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md'

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$COMPANY/docs" "$SOLUTION/docs"
git -C "$COMPANY" init -q
git -C "$SOLUTION" init -q
git -C "$COMPANY" remote add origin "https://github.com/example/company-ea.git"
git -C "$SOLUTION" remote add origin "https://example.com/org/sln-foo.git"

cp -R "$ROOT_DIR/company/solution-slots" "$COMPANY/docs/solution-slots"
printf '%s\n' 'links: []' >"$SOLUTION/docs/knowledge-links.yaml"

cat >"$COMPANY/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$COMPANY
DOC_DIR=docs
KNOWLEDGE_TYPE=company
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF

cat >"$SOLUTION/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$SOLUTION
DOC_DIR=docs
KNOWLEDGE_TYPE=solution
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF

run_link() {
  ( cd "$COMPANY" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --link --target "$SOLUTION" )
}

run_unlink() {
  ( cd "$COMPANY" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --unlink --target "$SOLUTION" )
}

run_link || fail "docs-link --link 应成功"
grep -Fq 'type: parent' "$SOLUTION/docs/knowledge-links.yaml" \
  || fail "link 后目标应含 type: parent"
assert_file_exists "$COMPANY/docs/knowledge-links.yaml"
grep -Fq 'solution_name: "sln-foo"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "link 后清单应含 sln-foo"

mkdir -p "$(dirname "$STUB")"
cat >"$STUB" <<EOF
## 依据与证据

- 上游：[BD-EXAMPLE]($HREF)
- 其它：保留
EOF

run_unlink || fail "docs-link --unlink 应成功"

grep -Fq 'type: parent' "$SOLUTION/docs/knowledge-links.yaml" \
  && fail "unlink 后不应残留 type: parent"
grep -Fq "$HREF" "$STUB" || fail "unlink 不应改正文跨层 HTTP"

if grep -Fq 'solution_name: "sln-foo"' "$COMPANY/docs/knowledge-links.yaml"; then
  fail "源仓 child 登记应已移除"
fi

pass "unlink 删除目标 type:parent，且不改正文 HTTP"
