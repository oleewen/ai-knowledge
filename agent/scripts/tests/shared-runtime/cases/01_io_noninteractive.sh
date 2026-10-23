#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
source "$SCRIPTS_ROOT/lib/log-io.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
unset IO_FORCE IO_CONFLICT_MODE IO_DRY_RUN DRY_RUN
printf 'new\n' >"$TMP_DIR/src"
printf 'old\n' >"$TMP_DIR/dst"
backup_probe() { : >"$TMP_DIR/backup-called"; }
IO_BACKUP_FN=backup_probe
rc=0
io_should_overwrite "$TMP_DIR/dst" </dev/null || rc=$?
[[ "$rc" == 3 ]] || fail '非交互覆盖决策必须返回未授权冲突 3'
rc=0
io_copy_file "$TMP_DIR/src" "$TMP_DIR/dst" </dev/null || rc=$?
[[ "$rc" == 3 && "$(cat "$TMP_DIR/dst")" == old ]] || fail '未授权文件拷贝必须返回 3 并保留目标'
[[ ! -e "$TMP_DIR/backup-called" ]] || fail '授权前不可执行 backup'
ln -s "$TMP_DIR/missing" "$TMP_DIR/dangling"
rc=0
io_copy_file "$TMP_DIR/src" "$TMP_DIR/dangling" </dev/null || rc=$?
[[ "$rc" == 3 && -L "$TMP_DIR/dangling" && ! -e "$TMP_DIR/missing" ]] || fail '已有悬空软链同样需要覆盖授权'
io_copy_file "$TMP_DIR/src" "$TMP_DIR/new/file" </dev/null
cmp "$TMP_DIR/src" "$TMP_DIR/new/file" || fail '新目标应允许创建'
IO_CONFLICT_MODE=skip_all
rc=0
io_copy_file "$TMP_DIR/src" "$TMP_DIR/dst" </dev/null || rc=$?
[[ "$rc" == 1 && "$(cat "$TMP_DIR/dst")" == old ]] || fail 'skip_all 必须保留 1'
IO_CONFLICT_MODE=overwrite_all
io_copy_file "$TMP_DIR/src" "$TMP_DIR/dst" </dev/null
cmp "$TMP_DIR/src" "$TMP_DIR/dst" || fail 'overwrite_all 未覆盖'
[[ -f "$TMP_DIR/backup-called" ]] || fail '授权覆盖仍应执行 backup'
unset IO_CONFLICT_MODE
printf 'old\n' >"$TMP_DIR/dst"
IO_FORCE=1 io_copy_file "$TMP_DIR/src" "$TMP_DIR/dst" </dev/null
cmp "$TMP_DIR/src" "$TMP_DIR/dst" || fail 'force 未覆盖'
IO_DRY_RUN=1 io_copy_file "$TMP_DIR/src" "$TMP_DIR/preview/file" </dev/null
[[ ! -e "$TMP_DIR/preview" ]] || fail 'dry-run 不可创建目录'
rc=0
(io_should_overwrite() { return 2; }; io_copy_file "$TMP_DIR/src" "$TMP_DIR/dst") || rc=$?
[[ "$rc" == 130 ]] || fail '取消决策 2 必须转换为 130'
pass '文件覆盖需明确授权，保留 skip/force/dry-run/cancel 契约'
