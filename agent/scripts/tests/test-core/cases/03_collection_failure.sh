#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/test-core.sh"

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/empty"
for path in "$fixture/missing" "$fixture/empty"; do
  if output="$(test_collect_case_scripts "$path" 2>"$fixture/error")"; then
    fail '缺目录或无用例收集返回了成功'
  fi
  [[ -z "$output" && -s "$fixture/error" ]] || fail '收集失败输出契约改变'
done

# 旧消费者使用进程替换，收集子进程退出码不能传播；运行器仍须阻止假绿。
CASES=()
while IFS= read -r file; do CASES+=("$file"); done < <(test_collect_case_scripts "$fixture/missing" 2>/dev/null)
if (test_run_case_suite '收集失败套件' "$BASH" "${CASES[@]}") >/dev/null 2>&1; then
  fail '缺目录收集后套件返回了成功'
fi
pass '缺目录及无用例收集失败，进程替换也不能导致假绿'
