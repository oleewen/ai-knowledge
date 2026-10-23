#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_ROOT/../../test-core.sh"

case_list="$(test_collect_case_scripts "$TEST_ROOT/cases")"
mapfile -t CASES <<<"$case_list"
test_run_case_suite 'test-core 回归' "$BASH" "${CASES[@]}"
