#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/lib/backup.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shared-config-parent.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT
TEST_ROOT="$(cd "$TEST_ROOT" && pwd -P)"
mkdir -p "$TEST_ROOT/repo/nested" "$TEST_ROOT/entity"
ln -s "$TEST_ROOT/repo" "$TEST_ROOT/alias"
printf 'entity\n' > "$TEST_ROOT/entity/data"
printf 'plain\n' > "$TEST_ROOT/repo/nested/plain"
[[ "$(backup_rel_under_root "$TEST_ROOT/repo" "$TEST_ROOT/alias/nested/plain")" == nested/plain ]]
ln -s "$TEST_ROOT/entity/data" "$TEST_ROOT/repo/nested/file-link"
ln -s '../missing' "$TEST_ROOT/repo/nested/broken-link"
ln -s "$TEST_ROOT/entity" "$TEST_ROOT/repo/nested/directory-link"
failures=0
for name in file-link broken-link directory-link; do
  link_path="$TEST_ROOT/alias/nested/$name"
  link_target="$(readlink "$link_path")"
  actual="$(backup_rel_under_root "$TEST_ROOT/repo" "$link_path")"
  if [[ "$actual" != "nested/$name" ]]; then
    printf 'FAIL: 软链父目录下 %s 相对路径: %s\n' "$name" "$actual" >&2
    failures=$((failures + 1))
    continue
  fi
  docs_backup_path_to_init "$TEST_ROOT/repo" "$link_path" preview 1 > "$TEST_ROOT/preview"
  [[ -L "$link_path" && ! -e "$TEST_ROOT/repo/.docs-init/preview" ]]
  docs_backup_path_to_init "$TEST_ROOT/repo" "$link_path" fixed > "$TEST_ROOT/stdout"
  [[ ! -L "$link_path" && -L "$TEST_ROOT/repo/.docs-init/fixed/nested/$name" ]]
  [[ "$(readlink "$TEST_ROOT/repo/.docs-init/fixed/nested/$name")" == "$link_target" ]]
done
[[ "$failures" == 0 ]]
[[ "$(cat "$TEST_ROOT/entity/data")" == entity ]]
[[ "$(cat "$TEST_ROOT/repo/nested/plain")" == plain ]]
printf 'PASS: 软链父目录物理归一化且保留末段各类链接\n'
