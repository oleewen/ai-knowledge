#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"

for option in meta scope target workspace agents; do
  if run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --"$option" --dry-run >"$FIXTURE/out" 2>&1; then
    fail "缺少 --$option 值时应失败"
  fi
  assert_dir_not_exists "$FIXTURE/.agents"
done

for value in 'a,invalid' 'a,cursor' 'cursor,all' 'all,invalid' ',,,'; do
  if run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --agents="$value" >"$FIXTURE/out" 2>&1; then
    fail "无效 agents 列表应失败: $value"
  fi
  assert_dir_not_exists "$FIXTURE/.agents"
done

AGENTS_OPT=codex run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=r >"$FIXTURE/out" 2>&1
assert_dir_exists "$FIXTURE/.codex"
assert_dir_not_exists "$FIXTURE/.cursor"
AGENTS_OPT=invalid run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=r --agents cursor trae >"$FIXTURE/out" 2>&1
assert_dir_exists "$FIXTURE/.cursor"
assert_dir_exists "$FIXTURE/.trae"
pass "CLI 缺值、非法 agents 均不写入；CLI 优先于环境默认值"
