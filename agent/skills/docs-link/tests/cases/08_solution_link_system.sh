#!/usr/bin/env bash
# solution → system：槽位 system-slots，parent 写 solution_*
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
SOLUTION="$FAKEHOME/ws/sln-kb"
SYSTEM="$FAKEHOME/ws/sys-foo"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$SOLUTION/docs" "$SYSTEM/docs"
git -C "$SOLUTION" init -q
git -C "$SYSTEM" init -q
git -C "$SOLUTION" remote add origin "https://example.com/org/sln-kb.git"
git -C "$SYSTEM" remote add origin "https://example.com/org/sys-foo.git"

cp -R "$ROOT_DIR/solution/system-slots" "$SOLUTION/docs/system-slots"
printf '%s\n' 'links: []' >"$SYSTEM/docs/knowledge-links.yaml"

cat >"$SOLUTION/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$SOLUTION
DOC_DIR=docs
KNOWLEDGE_TYPE=solution
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF

cat >"$SYSTEM/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$SYSTEM
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF

( cd "$SOLUTION" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --link --target "$SYSTEM" ) \
  || fail "docs-link --link 应成功"

grep -Fq 'sys_name: "sys-foo"' "$SOLUTION/docs/knowledge-links.yaml" \
  || fail "源仓应写 sys_name"
assert_dir_exists "$SOLUTION/docs/system-slots/system-sys-foo"
grep -Fq 'type: parent' "$SYSTEM/docs/knowledge-links.yaml" \
  || fail "目标应含 type: parent"
grep -Fq 'solution_name: "sln-kb"' "$SYSTEM/docs/knowledge-links.yaml" \
  || fail "parent.solution_name 应为源仓目录名"

pass "solution→system 建联写 sys_* 与 solution_* parent"
