#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$TEST_ROOT/cases"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  echo "[SKIP] docs-okf tests require Bash 5+"
  exit 0
fi

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

shopt -s nullglob
cases=( "$CASE_DIR"/*.sh )
shopt -u nullglob
((${#cases[@]})) || fail "no cases in $CASE_DIR"

IFS=$'\n' sorted=( $(printf '%s\n' "${cases[@]}" | sort) )
unset IFS

for f in "${sorted[@]}"; do
  printf '>>> %s\n' "$(basename "$f")"
  "${BASH:-$(command -v bash)}" "$f"
done

export BASH
python3 -B "$TEST_ROOT/test_entrypoints.py"
python3 -B "$TEST_ROOT/test_validation.py"
python3 -B "$TEST_ROOT/test_artifact_safety.py"
python3 -B "$TEST_ROOT/test_visualize_security.py"

echo "[OK] docs-okf tests passed"
