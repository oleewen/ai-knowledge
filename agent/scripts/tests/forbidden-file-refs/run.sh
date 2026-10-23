#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$TEST_ROOT/cases"
source "$TEST_ROOT/../../test-core.sh"
case_list="$(test_collect_case_scripts "$CASE_DIR")"
mapfile -t CASES <<< "$case_list"
test_run_case_suite 'forbidden-file-refs 回归' "$BASH" "${CASES[@]}"
