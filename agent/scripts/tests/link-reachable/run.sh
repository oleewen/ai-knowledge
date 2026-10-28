#!/usr/bin/env bash
set -euo pipefail
TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_ROOT/../../lib/bash.sh"
TEST_BASH="$BASH" python3 -B -m unittest discover -s "$TEST_ROOT" -v

# 校验当前元仓，避免个人 WORK_SPACE 将 quick 重定向到另一份检出。
# 消费库的配置/.agents 解析通过上方隔离测试与公开 Shell 入口验证。
CHECK_REPO="$(cd "$TEST_ROOT/../../../.." && pwd)"
REPO_ABS="$CHECK_REPO" DOC_ABS="$CHECK_REPO" AGENT_TREE="$CHECK_REPO/agent" \
  INSTALLED_AGENT="$CHECK_REPO/agent" \
  python3 -B "$TEST_ROOT/../../tools/validate_link_reachable.py" --scope root-layers
