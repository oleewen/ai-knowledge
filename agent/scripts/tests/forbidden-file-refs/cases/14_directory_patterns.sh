#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture
mkdir -p "$SCAN_REPO/.superpowers/sdd/""run"
for suffix in '' specs/ plans/ sdd/ sdd/run/ 'specs/YYYY-MM-DD-<topic>.md' 'plans/*.md' '{specs,plans,sdd}/'; do
  printf '`%s/%s`\n' .superpowers "$suffix" >> "$SCAN_REPO/README.md"
done
run_scan_fixture
[[ "$SCAN_STATUS" -eq 0 ]] || fail '目录模式和占位模式应允许'
pass '允许目录与占位模式说明'
