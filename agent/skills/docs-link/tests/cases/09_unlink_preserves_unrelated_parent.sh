#!/usr/bin/env bash
# unlink 仅移除本次目标对应 parent，保留子仓其它 parent
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
OTHER="$FAKEHOME/ws/other-solution"

cleanup() {
  rm -rf "$TMP_DIR"
  rm -f "$ROOT_DIR/agent/configs"
}
trap cleanup EXIT

mkdir -p "$SOLUTION/docs" "$SYSTEM/docs" "$OTHER/docs"
git -C "$SOLUTION" init -q
git -C "$SYSTEM" init -q
git -C "$OTHER" init -q
git -C "$SOLUTION" remote add origin "https://example.com/org/sln-kb.git"
git -C "$SYSTEM" remote add origin "https://example.com/org/sys-foo.git"
git -C "$OTHER" remote add origin "https://example.com/org/other-sln.git"

cp -R "$ROOT_DIR/solution/system-slots" "$SOLUTION/docs/system-slots"

cat >"$SOLUTION/docs/knowledge-links.yaml" <<EOF
links:
  - type: child
    repository: "https://example.com/org/sys-foo.git"
    path: "\${WORK_SPACE}/sys-foo"
    dir: "docs"
    name: "sys-foo"
    label: "sys-foo"
EOF

cat >"$SOLUTION/.docsconfig" <<EOF
REPO_DIR=$(basename "$SOLUTION")
DOC_DIR=docs
KNOWLEDGE_TYPE=solution
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF
pin_workspace_for_repo "$SOLUTION" "$ROOT_DIR" agent

cat >"$SYSTEM/.docsconfig" <<EOF
REPO_DIR=$(basename "$SYSTEM")
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF
pin_workspace_for_repo "$SYSTEM" "$ROOT_DIR" agent

cat >"$SYSTEM/docs/knowledge-links.yaml" <<EOF
links:
  - type: parent
    repository: "https://example.com/org/other-sln.git"
    path: "\${WORK_SPACE}/other-solution"
    dir: "docs"
    name: "other-solution"
    label: "other-solution"
  - type: meta
    repository: "git@github.com:oleewen/ai-knowledge.git"
    path: "\${WORK_SPACE}/ai-knowledge"
    dir: "system"
EOF

run_unlink() {
  ( cd "$SOLUTION" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --unlink --target "$SYSTEM" )
}

run_unlink || fail "docs-link --unlink 应成功"

grep -Fq 'repository: "https://example.com/org/other-sln.git"' "$SYSTEM/docs/knowledge-links.yaml" \
  || fail "unlink 应保留其它 parent"
grep -Fq 'name: "other-solution"' "$SYSTEM/docs/knowledge-links.yaml" \
  || fail "unlink 应保留其它 parent 条目"
! grep -Fq 'repository: "https://example.com/org/sys-foo.git"' "$SYSTEM/docs/knowledge-links.yaml" \
  || fail "unlink 应移除本次目标 parent"

pass "unlink 保留子仓其它 parent"
