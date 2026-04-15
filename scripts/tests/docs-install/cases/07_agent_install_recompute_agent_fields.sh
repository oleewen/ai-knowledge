#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case07.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

# 先生成 .docsconfig，再注入旧 AGENT_*，用于验证 agent-install 会重算覆盖
bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target="$DOCS_DIR" >"$OUT_FILE" 2>&1
cat >"$PROJECT_DIR/.docsconfig" <<EOF
DOC_ROOT=$DOCS_DIR
REPO_ROOT=$PROJECT_DIR
DOC_DIR=docs
KNOWLEDGE_TYPE=application
AGENT_ROOT=/tmp/legacy-agent-root
AGENT_DIRS=".cursor"
EOF

# 非 a 的 scope 也应触发重算覆盖
bash "$AGENT_INSTALL_SCRIPT" --scope=r --target="$PROJECT_DIR" --agents=claude >>"$OUT_FILE" 2>&1

DOCS_CONFIG_PATH="$PROJECT_DIR/.docsconfig"
EXPECTED_PROJECT="$(cd "$PROJECT_DIR" && pwd -P)"
assert_file_exists "$DOCS_CONFIG_PATH"
assert_contains "AGENT_ROOT=$EXPECTED_PROJECT" "$DOCS_CONFIG_PATH"
assert_contains "AGENT_DIRS=\".claude\"" "$DOCS_CONFIG_PATH"

pass "agent-install 任意 scope 安装后重算并覆盖 AGENT_*"
