#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT

for option in --scope=invalid --agents=invalid --scope= --agents= --target= --workspace= --meta=; do
  if run_agent_install "$FAKE_HOME" "$option" >"$FAKE_HOME/out.txt" 2>&1; then
    fail "无效参数应失败: $option"
  fi
  assert_dir_not_exists "$FAKE_HOME/.agents"
done
pass "无效参数在创建安装树前失败"
