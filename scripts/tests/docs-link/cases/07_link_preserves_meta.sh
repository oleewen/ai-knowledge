#!/usr/bin/env bash
# link 写回保活目标/源仓已有 type:meta
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

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$COMPANY/docs" "$SYSTEM/docs"
git -C "$COMPANY" init -q
git -C "$SYSTEM" init -q
git -C "$COMPANY" remote add origin "https://github.com/example/company-ea.git"
git -C "$SYSTEM" remote add origin "https://example.com/org/sys-foo.git"

cp -R "$ROOT_DIR/company/system-SYSNAME" "$COMPANY/docs/system-SYSNAME"

cat >"$COMPANY/docs/knowledge-links.yaml" <<'EOF'
links:
  - type: meta
    repository: "https://example.com/org/ai-knowledge.git"
    path: "~/workspaces/ai-knowledge"
    doc_dir: "company"
EOF

cat >"$SYSTEM/docs/knowledge-links.yaml" <<'EOF'
links:
  - type: meta
    repository: "https://example.com/org/ai-knowledge.git"
    path: "~/workspaces/ai-knowledge"
    doc_dir: "system"
EOF

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

( cd "$COMPANY" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --link --target "$SYSTEM" ) \
  || fail "docs-link --link 应成功"

grep -Fq 'type: meta' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "源仓 links 写回后应保留 type: meta"
grep -Fq 'doc_dir: "company"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "源仓 meta.doc_dir 应仍为 company"
grep -Fq 'sys_name: "sys-foo"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "源仓应同时含 child sys-foo"

grep -Fq 'type: meta' "$SYSTEM/docs/knowledge-links.yaml" \
  || fail "目标 links 写回后应保留 type: meta"
grep -Fq 'type: parent' "$SYSTEM/docs/knowledge-links.yaml" \
  || fail "目标应含 type: parent"
grep -Fq 'doc_dir: "system"' "$SYSTEM/docs/knowledge-links.yaml" \
  || fail "目标 meta.doc_dir 应仍为 system"

pass "link 写回保活 type:meta"
