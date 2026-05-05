#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$TEST_ROOT/cases"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  printf '跳过 docs-push 测试：需要 Bash 5+（当前 %s）\n' "${BASH_VERSION:-?}" >&2
  exit 0
fi

if [[ ! -d "$CASE_DIR" ]]; then
  printf '未找到测试目录: %s\n' "$CASE_DIR" >&2
  exit 1
fi

mapfile -t CASES < <(ls "$CASE_DIR"/*.sh 2>/dev/null | sort)

if [[ "${#CASES[@]}" -eq 0 ]]; then
  printf '未发现测试用例: %s\n' "$CASE_DIR" >&2
  exit 1
fi

total=0
passed=0
failed=0

printf '== docs-push 测试 ==\n'

for case_file in "${CASES[@]}"; do
  total=$((total + 1))
  case_name="$(basename "$case_file")"
  printf '\n[%d/%d] %s\n' "$total" "${#CASES[@]}" "$case_name"
  if "${BASH:-bash}" "$case_file"; then
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
