#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/lib/docsconfig.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shared-config-backup.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT
TEST_ROOT="$(cd "$TEST_ROOT" && pwd -P)"
printf 'old\n' > "$TEST_ROOT/config"
docs_backup_path_to_init "$TEST_ROOT" "$TEST_ROOT/config" fixed > "$TEST_ROOT/stdout" 2> "$TEST_ROOT/stderr"
[[ -f "$TEST_ROOT/.docs-init/fixed/config" ]]
[[ ! -e "$TEST_ROOT/config" ]]
[[ ! -s "$TEST_ROOT/stderr" ]]
[[ "$(cat "$TEST_ROOT/stdout")" == "已备份：$TEST_ROOT/config → $TEST_ROOT/.docs-init/fixed/config" ]]
printf 'PASS: docsconfig 轻量备份\n'
