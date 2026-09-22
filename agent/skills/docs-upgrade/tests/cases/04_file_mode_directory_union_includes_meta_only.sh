#!/usr/bin/env bash
# 文件模式指定目录必须取本库/元库相对路径并集；meta-only 不得漏出 scaffold 总览
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROTOCOL="$TMP_DIR/protocol.md"
SKILL_DOCS=(
  "$ROOT_DIR/agent/skills/docs-upgrade/SKILL.md"
  "$ROOT_DIR/agent/skills/docs-upgrade/references/parameters.md"
  "$ROOT_DIR/agent/skills/docs-upgrade/references/workflow.md"
  "$ROOT_DIR/agent/skills/docs-upgrade/agents/grader.md"
)

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TMP_DIR"

cat >"$PROTOCOL" <<'EOF'
# File-mode directory overview

Selected: docs/knowledge/business/

Path matrix:
- both: knowledge/business/README.md -> force refill
- local-only: knowledge/business/BSD-LOCAL.md -> meta missing reject
- meta-only: knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md -> scaffold
- meta-only: knowledge/business/BD-EXAMPLE/index.md -> scaffold

Union count: 4; action count: 4.
C execute all processable items / M change scope / S cancel / F no tree expansion.
EOF

for doc in "${SKILL_DOCS[@]}"; do
  assert_contains "并集" "$doc"
  assert_contains "meta-only" "$doc"
done

assert_contains "meta-only" "$PROTOCOL"
assert_contains "Union count: 4; action count: 4" "$PROTOCOL"
assert_contains "BD-EXAMPLE/BD-EXAMPLE.md -> scaffold" "$PROTOCOL"

pass "文件模式指定目录扫描两侧并集，meta-only scaffold 不漏项"
