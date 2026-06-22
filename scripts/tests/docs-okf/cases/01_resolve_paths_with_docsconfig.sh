#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

[[ -f "$RESOLVE_SCRIPT" ]] || fail "缺少 resolve 脚本: $RESOLVE_SCRIPT"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
FAKE_SCRIPT_DIR="$PROJECT_DIR/bin"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$DOCS_DIR/knowledge" "$FAKE_SCRIPT_DIR"
git -C "$PROJECT_DIR" init -q
write_docsconfig "$PROJECT_DIR" "$DOCS_DIR" "$PROJECT_DIR" "docs" "application"

# shellcheck disable=SC1091
source "$RESOLVE_SCRIPT"
resolve_okf_paths "$FAKE_SCRIPT_DIR"

[[ "$OKF_BUNDLE" == "docs" ]] || fail "OKF_BUNDLE 应为 docs，得: $OKF_BUNDLE"
[[ "$OKF_VIZ_OUT" == "application/viz.html" ]] || fail "OKF_VIZ_OUT 错误: $OKF_VIZ_OUT"
[[ "$OKF_VIZ_NAME" == "application OKF" ]] || fail "OKF_VIZ_NAME 错误: $OKF_VIZ_NAME"
[[ "$(cd "$REPO_ROOT" && pwd -P)" == "$(cd "$PROJECT_DIR" && pwd -P)" ]] || fail "REPO_ROOT 错误: $REPO_ROOT (expected $PROJECT_DIR)"
[[ "$DOC_DIR" == "docs" ]] || fail "DOC_DIR 错误: $DOC_DIR"
[[ "$KNOWLEDGE_TYPE" == "application" ]] || fail "KNOWLEDGE_TYPE 错误: $KNOWLEDGE_TYPE"

pass "resolve-okf-paths 正确解析 DOC_DIR 与 KNOWLEDGE_TYPE"
