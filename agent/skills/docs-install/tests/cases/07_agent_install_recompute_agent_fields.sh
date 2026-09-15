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

bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target "$DOCS_DIR" >"$OUT_FILE" 2>&1
cat >"$PROJECT_DIR/.docsconfig" <<EOF
DOC_ROOT=$DOCS_DIR
REPO_ROOT=$PROJECT_DIR
DOC_DIR=docs
KNOWLEDGE_TYPE=application
AGENT_ROOT=/tmp/legacy-agent-root
EOF

bash "$AGENT_INSTALL_SCRIPT" --scope=r --target="$PROJECT_DIR" --agents=claude >>"$OUT_FILE" 2>&1

DOCS_CONFIG_PATH="$PROJECT_DIR/.docsconfig"
assert_file_exists "$DOCS_CONFIG_PATH"
assert_contains "AGENT_ROOT=" "$DOCS_CONFIG_PATH"
assert_contains ".agents" "$DOCS_CONFIG_PATH"
if rg --fixed-strings "/tmp/legacy-agent-root" "$DOCS_CONFIG_PATH" >/dev/null; then
  fail "应覆盖旧 AGENT_ROOT: $DOCS_CONFIG_PATH"
fi

pass "agent-install 任意 scope 安装后重算并覆盖 AGENT_ROOT=~/.agents"
