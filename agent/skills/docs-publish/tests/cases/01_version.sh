#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"; source "$ROOT/agent/scripts/lib/version.sh"; source "$ROOT/agent/scripts/test-core.sh"
[[ "$(version_normalize 26.10.20)" == 2026.1020.0 ]]
[[ "$(version_normalize 2026.1020.3)" == 2026.1020.3 ]]
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
for layer in application system solution company; do mkdir -p "$TMP/$layer"; printf 'version: 2026.1020.3\n' >"$TMP/$layer/DESIGN.md"; done
[[ "$(version_next_from_files "$TMP"/*/DESIGN.md)" == 2026.1020.4 ]]
pass '版本解析与 patch 递增'
