#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/test-core.sh"

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/cases/nested"
printf 'exit 0\n' >"$fixture/cases/20_pass.sh"
printf 'exit 7\n' >"$fixture/cases/10_fail.sh"
printf 'exit 9\n' >"$fixture/cases/nested/01_ignored.sh"
printf 'ignored\n' >"$fixture/cases/ignored.txt"
list="$(test_collect_case_scripts "$fixture/cases")"
[[ "$list" == "$fixture/cases/10_fail.sh"$'\n'"$fixture/cases/20_pass.sh" ]] || fail '用例收集顺序或范围改变'
mapfile -t CASES <<<"$list"
if test_run_case_suite '混合套件' "$BASH" "${CASES[@]}" >"$fixture/output"; then
  fail '失败用例未传播到套件退出码'
fi
assert_contains '总计: 2, 通过: 1, 失败: 1' "$fixture/output"
test_run_case_suite '成功套件' '' "$fixture/cases/20_pass.sh" >"$fixture/output"
assert_contains '总计: 1, 通过: 1, 失败: 0' "$fixture/output"
pass '收集保持顶层排序，运行器继续执行并汇总失败'
