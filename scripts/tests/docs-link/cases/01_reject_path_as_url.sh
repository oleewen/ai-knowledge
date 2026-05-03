#!/usr/bin/env bash
# knowledge-links.yaml 中 path 不得为 URL（须使用 repository）
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
SRC="$TMP_DIR/src"
DOCS_LINK="$ROOT_DIR/scripts/docs-link.sh"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$SRC/docs"
git -C "$SRC" init -q

cat >"$SRC/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$SRC
DOC_DIR=application
KNOWLEDGE_TYPE=system
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

cat >"$SRC/docs/knowledge-links.yaml" <<'EOF'
# 知识库建联清单（可由 docs-link.sh 维护）
links:
  - path: "https://evil.example/repo.git"
EOF

set +e
out="$(cd "$SRC" && "${BASH:-bash}" "$DOCS_LINK" --unlink --target=/tmp/docs-link-test-nonexistent-path 2>&1)"
code=$?
set -e

[[ "$code" -ne 0 ]] || fail "应对非法 path=URL 的 YAML 非零退出"
printf '%s\n' "$out" | grep -Fq 'path 不得为远程 URL' || fail "stderr 应提示 path 不得为远程 URL"

pass "拒绝 path 字段承载 URL 的旧形态"
