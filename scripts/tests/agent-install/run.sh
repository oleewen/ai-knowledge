#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$TEST_ROOT/cases"

mapfile -t CASES < <(ls "$CASE_DIR"/*.sh 2>/dev/null | sort)

if [[ "${#CASES[@]}" -eq 0 ]]; then
  printf '未发现测试用例: %s\n' "$CASE_DIR" >&2
  exit 1
fi

total=0 passed=0 failed=0

printf '== agent-install 基线测试 ==\n'

for case_file in "${CASES[@]}"; do
  total=$((total + 1))
  case_name="$(basename "$case_file")"
  printf '\n[%d/%d] %s\n' "$total" "${#CASES[@]}" "$case_name"
  if bash "$case_file"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
  fi
done

printf '\n== 测试结果 ==\n'
printf '总计: %d, 通过: %d, 失败: %d\n' "$total" "$passed" "$failed"

if [[ "$failed" -gt 0 ]]; then
  exit 1
fi
