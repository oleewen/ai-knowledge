#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

bash "$DOCS_INSTALL_SCRIPT" \
  --scope=knowledge \
  --mode=central \
  --type=application \
  --target "$DOCS_DIR" >/dev/null 2>&1

assert_file_exists "$DOCS_DIR/docs-meta.md"
assert_file_not_exists "$DOCS_DIR/docs_meta.md"

pass "central 子集安装 docs-meta.md"
