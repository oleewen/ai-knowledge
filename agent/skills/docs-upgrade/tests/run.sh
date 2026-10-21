#!/usr/bin/env bash
set -euo pipefail

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  echo "[ERROR] docs-upgrade tests require Bash 5+" >&2
  exit 1
fi

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$TEST_ROOT/cases"
source "$TEST_ROOT/test-lib.sh"

CASES=()
while IFS= read -r case_file; do CASES+=("$case_file"); done < <(test_collect_case_scripts "$CASE_DIR")
test_run_case_suite 'docs-upgrade 脚本与 fixture 测试' "${BASH:-$(command -v bash)}" "${CASES[@]}"
