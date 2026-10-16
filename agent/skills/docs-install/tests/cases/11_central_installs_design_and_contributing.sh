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

assert_file_exists "$DOCS_DIR/DESIGN.md"
[[ ! -e "$DOCS_DIR/CONTRIBUTING.md" ]] || fail "central 子集不应再种 CONTRIBUTING.md"
[[ ! -e "$DOCS_DIR/manifest.md" ]] || fail "central 子集不应再种 manifest.md"

pass "central 子集安装根级 DESIGN.md（不含 CONTRIBUTING/manifest）"
