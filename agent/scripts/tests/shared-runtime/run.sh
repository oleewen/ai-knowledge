#!/usr/bin/env bash
set -euo pipefail
TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_ROOT="$(cd "$TEST_ROOT/../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
CASES_TEXT="$(test_collect_case_scripts "$TEST_ROOT/cases")"
mapfile -t CASES <<<"$CASES_TEXT"
test_run_case_suite '共享运行契约测试' "${BASH:-bash}" "${CASES[@]}"
