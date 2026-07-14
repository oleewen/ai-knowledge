#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_ROOT/../../.." && pwd)"
CASE_DIR="$TEST_ROOT/cases"
source "$REPO_ROOT/agent/scripts/test-core.sh"

mapfile -t CASES < <(test_collect_case_scripts "$CASE_DIR")
test_run_case_suite 'agent-install 基线测试' "${BASH:-bash}" "${CASES[@]}"
