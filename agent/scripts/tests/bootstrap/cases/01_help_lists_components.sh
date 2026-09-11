#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

OUT_FILE="$(mktemp "${TMPDIR:-/tmp}/docs-bootstrap-help.XXXXXX")"
cleanup() { rm -f "$OUT_FILE"; }
trap cleanup EXIT

bash "$DOCS_BOOTSTRAP_SCRIPT" -h >"$OUT_FILE" 2>&1 || true

grep -q -- '--components=docs|agent|both' "$OUT_FILE" \
  || fail "帮助未列出 --components=docs|agent|both"
grep -q '仅 Agent' "$OUT_FILE" \
  || fail "帮助未含仅 Agent 示例"

pass "帮助列出 --components 与 agent-only 示例"
