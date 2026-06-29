#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_ROOT/../../.." && pwd)"
CASE_DIR="$TEST_ROOT/cases"
source "$REPO_ROOT/agent/scripts/test-core.sh"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  printf '跳过 docs-push 测试：需要 Bash 5+（当前 %s）\n' "${BASH_VERSION:-?}" >&2
  exit 0
fi

mapfile -t CASES < <(test_collect_case_scripts "$CASE_DIR")
test_run_case_suite 'docs-push 测试' "${BASH:-bash}" "${CASES[@]}"
