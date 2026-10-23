#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/test-core.sh"

if (test_run_case_suite '空套件' "$BASH") >/dev/null 2>&1; then
  fail '零用例套件返回了成功'
fi
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
if (set +e; test_run_case_suite '仅标题') >"$fixture/output" 2>&1; then
  fail '仅标题调用在无 errexit 时返回了成功'
fi
assert_contains '未提供测试用例: 仅标题' "$fixture/output"
assert_not_contains '总计:' "$fixture/output"
pass '零用例套件必须失败'
