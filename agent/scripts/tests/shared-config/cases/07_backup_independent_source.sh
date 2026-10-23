#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
unset _LIB_DIR
source "$SCRIPTS_ROOT/lib/backup.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shared-config-independent.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT
TEST_ROOT="$(cd "$TEST_ROOT" && pwd -P)"
printf old > "$TEST_ROOT/source"
docs_backup_path_to_init "$TEST_ROOT" "$TEST_ROOT/source" fixed > "$TEST_ROOT/stdout" 2> "$TEST_ROOT/stderr"
[[ "$(cat "$TEST_ROOT/.docs-init/fixed/source")" == old && ! -s "$TEST_ROOT/stderr" ]]
[[ "$(cat "$TEST_ROOT/stdout")" == "已备份：$TEST_ROOT/source → $TEST_ROOT/.docs-init/fixed/source" ]]
printf 'PASS: backup 独立加载且保留轻量日志流\n'
