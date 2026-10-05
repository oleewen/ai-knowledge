#!/usr/bin/env bash
# link 写回保活目标/源仓已有 type:meta（company → solution）
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

cat >"$COMPANY/docs/knowledge-links.yaml" <<'EOF'
links:
  - type: meta
    repository: "https://example.com/org/ai-knowledge.git"
    path: "~/workspaces/ai-knowledge"
    doc_dir: "company"
EOF

cat >"$SOLUTION/docs/knowledge-links.yaml" <<'EOF'
links:
  - type: meta
    repository: "https://example.com/org/ai-knowledge.git"
    path: "~/workspaces/ai-knowledge"
    doc_dir: "solution"
EOF

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

( cd "$COMPANY" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --link --target "$SOLUTION" ) \
  || fail "docs-link --link 应成功"

grep -Fq 'type: meta' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "源仓 links 写回后应保留 type: meta"
grep -Fq 'doc_dir: "company"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "源仓 meta.doc_dir 应仍为 company"
grep -Fq 'solution_name: "sln-foo"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "源仓应同时含 child sln-foo"

grep -Fq 'type: meta' "$SOLUTION/docs/knowledge-links.yaml" \
  || fail "目标 links 写回后应保留 type: meta"
grep -Fq 'type: parent' "$SOLUTION/docs/knowledge-links.yaml" \
  || fail "目标应含 type: parent"
grep -Fq 'doc_dir: "solution"' "$SOLUTION/docs/knowledge-links.yaml" \
  || fail "目标 meta.doc_dir 应仍为 solution"

pass "link 写回保活 type:meta"
