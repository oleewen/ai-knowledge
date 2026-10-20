#!/usr/bin/env bash
set -euo pipefail
[[ "${BASH_VERSINFO[0]:-0}" -ge 5 ]] || { echo '[SKIP] requires Bash 5+'; exit 0; }
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
source "$ROOT/agent/scripts/test-core.sh"
CASES=(); while IFS= read -r f; do CASES+=("$f"); done < <(test_collect_case_scripts "$(dirname "${BASH_SOURCE[0]}")/cases")
test_run_case_suite 'docs-publish 测试' "${BASH:-bash}" "${CASES[@]}"
