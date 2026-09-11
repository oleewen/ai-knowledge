#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case01.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

cat >"$PROJECT_DIR/.docsconfig" <<EOF
AGENT_ROOT=$PROJECT_DIR/missing-agent-root
AGENT_DIRS=".claude .cursor"
EOF

bash "$DOCS_INSTALL_SCRIPT" --scope=config --type=application --target="$DOCS_DIR" >"$OUT_FILE" 2>&1

DOCS_CONFIG_PATH="$PROJECT_DIR/.docsconfig"
assert_file_exists "$DOCS_CONFIG_PATH"
assert_contains "DOC_ROOT=" "$DOCS_CONFIG_PATH"
assert_contains "REPO_ROOT=" "$DOCS_CONFIG_PATH"
assert_contains "DOC_DIR=" "$DOCS_CONFIG_PATH"
if rg --fixed-strings "KNOWLEDGE_TYPE=" "$DOCS_CONFIG_PATH" >/dev/null; then
  fail "scope=config 不应写 KNOWLEDGE_TYPE: $DOCS_CONFIG_PATH"
fi

assert_contains "AGENT_ROOT=" "$DOCS_CONFIG_PATH"
assert_contains "AGENT_DIRS=" "$DOCS_CONFIG_PATH"
assert_contains "missing-agent-root" "$DOCS_CONFIG_PATH"
assert_contains "AGENT_DIRS=\".claude .cursor\"" "$DOCS_CONFIG_PATH"
pass "scope=config 写入 .docsconfig（不写 KNOWLEDGE_TYPE）"
