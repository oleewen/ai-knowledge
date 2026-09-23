#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
ensure_test_agent_home "$TMP_DIR"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case07.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target "$DOCS_DIR" >"$OUT_FILE" 2>&1
cat >"$PROJECT_DIR/.docsconfig" <<EOF
DOC_ROOT=$DOCS_DIR
REPO_ROOT=$PROJECT_DIR
DOC_DIR=docs
KNOWLEDGE_TYPE=application
AGENT_ROOT=~
AGENT_DIR=.agents
EOF

# 故意改成 legacy 值；agent-install 不应写回覆盖
cat >"$PROJECT_DIR/.docsconfig" <<EOF
DOC_ROOT=$DOCS_DIR
REPO_ROOT=$PROJECT_DIR
DOC_DIR=docs
KNOWLEDGE_TYPE=application
AGENT_ROOT=/tmp/legacy-agent-root
AGENT_DIR=.agents
EOF

bash "$AGENT_INSTALL_SCRIPT" --scope=r --target="$PROJECT_DIR" --agents=claude >>"$OUT_FILE" 2>&1

DOCS_CONFIG_PATH="$PROJECT_DIR/.docsconfig"
assert_file_exists "$DOCS_CONFIG_PATH"
assert_contains "/tmp/legacy-agent-root" "$DOCS_CONFIG_PATH"

pass "agent-install 不写回 .docsconfig 的 AGENT_ROOT/AGENT_DIR"
