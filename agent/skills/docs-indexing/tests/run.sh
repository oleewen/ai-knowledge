#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$TEST_ROOT/cases"

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

echo "[OK] docs-indexing tests passed"
