#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
ensure_test_agent_home "$TMP_DIR"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case09.out"

cleanup() {
 rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

"${BASH:-$(command -v bash)}" "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target "$DOCS_DIR" >"$OUT_FILE" 2>&1

assert_file_exists "$DOCS_DIR/README.md"
assert_file_exists "$DOCS_DIR/knowledge/README.md"
assert_file_exists "$DOCS_DIR/DESIGN.md"
[[ ! -e "$DOCS_DIR/CONTRIBUTING.md" ]] || fail "不应再安装 CONTRIBUTING.md"
[[ ! -e "$DOCS_DIR/manifest.md" ]] || fail "不应再安装 manifest.md"
[[ ! -e "$DOCS_DIR/changelogs" ]] || fail "不应再安装 changelogs/"

printf '\n%s\n' 'LOCAL-DESIGN-CUSTOM-MARKER' >>"$DOCS_DIR/DESIGN.md"
"${BASH:-$(command -v bash)}" "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target "$DOCS_DIR" --force >>"$OUT_FILE" 2>&1
assert_file_exists "$DOCS_DIR/DESIGN.md"
assert_not_contains "LOCAL-DESIGN-CUSTOM-MARKER" "$DOCS_DIR/DESIGN.md"

pass "standalone 全量安装同步子目录 README.md 与根级 DESIGN.md（重装整文件覆盖；不含 CONTRIBUTING/manifest）"
