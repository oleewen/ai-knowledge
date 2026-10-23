#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_ROOT="$(cd "$TEST_ROOT/../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"

mapfile -t cases < <(test_collect_case_scripts "$TEST_ROOT/cases")
test_run_case_suite '共享配置与备份' "${BASH}" "${cases[@]}"
