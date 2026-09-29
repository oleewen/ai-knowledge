#!/usr/bin/env bash
set -euo pipefail

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  echo "[SKIP] agent-install tests require Bash 5+"
  exit 0
fi

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_ROOT/../../../.." && pwd)"
CASE_DIR="$TEST_ROOT/cases"
source "$REPO_ROOT/agent/scripts/test-core.sh"

CASES=()
while IFS= read -r case_file; do CASES+=("$case_file"); done < <(test_collect_case_scripts "$CASE_DIR")
test_run_case_suite 'agent-install 基线测试' "${BASH:-$(command -v bash)}" "${CASES[@]}"
