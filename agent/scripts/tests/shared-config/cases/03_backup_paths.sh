#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/docs-core.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shared-config-paths.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT
TEST_ROOT="$(cd "$TEST_ROOT" && pwd -P)"
mkdir -p "$TEST_ROOT/repo/nested" "$TEST_ROOT/entity"
printf 'entity\n' > "$TEST_ROOT/entity/data"
ln -s "$TEST_ROOT/entity" "$TEST_ROOT/repo/nested/link"
actual="$(backup_rel_under_root "$TEST_ROOT/repo" "$TEST_ROOT/repo/nested/link")"
[[ "$actual" == 'nested/link' ]] || { printf 'FAIL: 目录软链备份相对路径: %s\n' "$actual" >&2; exit 1; }
docs_backup_path_to_init "$TEST_ROOT/repo" "$TEST_ROOT/repo/nested/link" fixed >/dev/null
[[ -L "$TEST_ROOT/repo/.docs-init/fixed/nested/link" ]]
[[ "$(readlink "$TEST_ROOT/repo/.docs-init/fixed/nested/link")" == "$TEST_ROOT/entity" ]]
[[ "$(cat "$TEST_ROOT/entity/data")" == entity ]]
ln -s '../missing' "$TEST_ROOT/repo/nested/link"
docs_backup_path_to_init "$TEST_ROOT/repo" "$TEST_ROOT/repo/nested/link" fixed >/dev/null
[[ "$(readlink "$TEST_ROOT/repo/.docs-init/fixed/nested/link.__1")" == '../missing' ]]
ln -s '../missing-again' "$TEST_ROOT/repo/nested/link"
docs_backup_path_to_init "$TEST_ROOT/repo" "$TEST_ROOT/repo/nested/link" fixed >/dev/null
[[ "$(readlink "$TEST_ROOT/repo/.docs-init/fixed/nested/link.__2")" == '../missing-again' ]]
printf 'keep\n' > "$TEST_ROOT/repo/nested/source"
docs_backup_path_to_init "$TEST_ROOT/repo" "$TEST_ROOT/repo/nested/source" preview 1 > "$TEST_ROOT/preview" 2>&1
[[ -f "$TEST_ROOT/repo/nested/source" && ! -e "$TEST_ROOT/repo/.docs-init/preview" ]]
[[ "$(cat "$TEST_ROOT/preview")" == *'[dry-run] 将备份：'* ]]
[[ "$(backup_rel_under_root "$TEST_ROOT/repo" "$TEST_ROOT/entity/data")" == "${TEST_ROOT#/}/entity/data" ]]
docs_backup_path_to_init "$TEST_ROOT/repo" "$TEST_ROOT/repo/missing" fixed
printf 'PASS: 软链、碰撞、dry-run 与根外路径\n'
