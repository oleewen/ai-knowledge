#!/usr/bin/env bash
# link 写入的 path 使用 WORK_SPACE 占位符（集成：company → solution）；子仓 links 写 type:parent
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
  rm -f "$ROOT_DIR/agent/configs"
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
REPO_DIR=$(basename "$COMPANY")
DOC_DIR=docs
KNOWLEDGE_TYPE=company
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF
pin_workspace_for_repo "$COMPANY" "$ROOT_DIR" agent

cat >"$SOLUTION/.docsconfig" <<EOF
REPO_DIR=$(basename "$SOLUTION")
DOC_DIR=docs
KNOWLEDGE_TYPE=solution
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF
pin_workspace_for_repo "$SOLUTION" "$ROOT_DIR" agent

( cd "$COMPANY" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --link --target "$SOLUTION" ) \
  || fail "docs-link --link 应成功"

assert_file_exists "$COMPANY/docs/knowledge-links.yaml"
grep -Fq 'path: "${WORK_SPACE}/sln-foo"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "path 应为 WORK_SPACE 占位符路径"
grep -Fq 'repository: "https://example.com/org/sln-foo.git"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "repository 应写入 target remote URL"
grep -Fq 'dir: "docs"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "dir 应为目标 .docsconfig 的 DOC_DIR"
grep -Fq 'name: "sln-foo"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "name 应写入"
grep -Fq 'label: "sln-foo"' "$COMPANY/docs/knowledge-links.yaml" \
  || fail "label 应写入"
assert_dir_exists "$COMPANY/docs/solution-slots/solution-sln-foo"

assert_file_exists "$SOLUTION/docs/knowledge-links.yaml"
grep -Fq 'type: parent' "$SOLUTION/docs/knowledge-links.yaml" \
  || fail "目标 links 应含 type: parent"
grep -Fq 'name: "company-repo"' "$SOLUTION/docs/knowledge-links.yaml" \
  || fail "parent.name 应为源仓目录名"
grep -Fq 'repository: "https://github.com/example/company-ea.git"' \
  "$SOLUTION/docs/knowledge-links.yaml" \
  || fail "parent.repository 应为源仓 origin"
grep -Fq 'dir: "docs"' "$SOLUTION/docs/knowledge-links.yaml" \
  || fail "parent.dir 应为源 DOC_DIR"

pass "link 写出 WORK_SPACE path、槽位，并在目标 links 写入 type:parent"
