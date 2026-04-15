#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case09.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target="$DOCS_DIR" >"$OUT_FILE" 2>&1

assert_file_exists "$DOCS_DIR/README.md"
assert_file_exists "$DOCS_DIR/knowledge/README.md"
assert_file_exists "$DOCS_DIR/changelogs/README.md"

pass "standalone 全量安装同步子目录 README.md"
