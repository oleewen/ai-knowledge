#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$TEST_ROOT/cases"

for case_file in "$CASE_DIR"/*.sh; do
  echo "== $(basename "$case_file") =="
  bash "$case_file"
done
