#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
ensure_test_agent_home "$TMP_DIR"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

"${BASH:-$(command -v bash)}" "$DOCS_INSTALL_SCRIPT" \
  --scope=knowledge \
  --mode=central \
  --type=application \
  --target "$DOCS_DIR" >/dev/null 2>&1

assert_file_not_exists "$DOCS_DIR/docs-meta.md"
assert_file_not_exists "$DOCS_DIR/docs_meta.md"
assert_file_not_exists "$DOCS_DIR/knowledge/knowledge-meta.md"
assert_file_exists "$DOCS_DIR/DESIGN.md"
assert_file_exists "$DOCS_DIR/CONTRIBUTING.md"

pass "central 子集不安装 docs-meta.md / knowledge-meta.md，仍安装根级 CONTRIBUTING.md / DESIGN.md"
