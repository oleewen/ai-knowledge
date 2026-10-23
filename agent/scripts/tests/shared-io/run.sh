#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_ROOT="$(cd "$TEST_ROOT/../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
mapfile -t CASES < <(test_collect_case_scripts "$TEST_ROOT/cases")
test_run_case_suite '共享 IO 与联邦清单测试' "${BASH:-bash}" "${CASES[@]}"
