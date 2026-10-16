#!/usr/bin/env bash
# knowledge-links.yaml 中 path 不得为 URL（须使用 repository）
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
SRC="$TMP_DIR/src"
DOCS_LINK="$ROOT_DIR/agent/skills/docs-link/scripts/docs-link.sh"

cleanup() {
  rm -rf "$TMP_DIR"
  rm -f "$ROOT_DIR/agent/configs"
}
trap cleanup EXIT

mkdir -p "$SRC/docs"
git -C "$SRC" init -q

cat >"$SRC/.docsconfig" <<EOF
REPO_DIR=$(basename "$SRC")
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF
pin_workspace_for_repo "$SRC" "$ROOT_DIR" agent

cat >"$SRC/docs/knowledge-links.yaml" <<'EOF'
# 知识库建联清单（可由 docs-link.sh 维护）
links:
  - type: child
    repository: "https://example.com/org/app.git"
    path: "https://evil.example/repo.git"
    name: "app"
EOF

set +e
out="$(cd "$SRC" && "${BASH:-bash}" "$DOCS_LINK" --unlink --target /tmp/docs-link-test-nonexistent-path 2>&1)"
code=$?
set -e

[[ "$code" -ne 0 ]] || fail "应对非法 path=URL 的 YAML 非零退出"
printf '%s\n' "$out" | grep -Fq 'path 不得为远程 URL' || fail "stderr 应提示 path 不得为远程 URL"

pass "拒绝 path 字段承载 URL 的旧形态"
