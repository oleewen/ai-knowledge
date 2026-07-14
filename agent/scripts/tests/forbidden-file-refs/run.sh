#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$TEST_ROOT/cases"

mapfile -t CASES < <(ls "$CASE_DIR"/*.sh 2>/dev/null | sort)

if [[ "${#CASES[@]}" -eq 0 ]]; then
  echo "未发现测试用例: $CASE_DIR" >&2
  exit 1
fi

total=0 passed=0 failed=0
echo "== forbidden-file-refs 基线测试 =="

for case_file in "${CASES[@]}"; do
  total=$((total + 1))
  name="$(basename "$case_file")"
  echo ""
  echo "[$total/${#CASES[@]}] $name"
  if bash "$case_file"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
  fi
done

echo ""
echo "== 测试结果 =="
echo "总计: $total, 通过: $passed, 失败: $failed"
[[ "$failed" -eq 0 ]]
