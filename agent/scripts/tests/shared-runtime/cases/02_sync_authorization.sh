#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
source "$SCRIPTS_ROOT/lib/log-io.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
unset IO_FORCE IO_CONFLICT_MODE IO_DRY_RUN DRY_RUN
mkdir -p "$TMP_DIR/src" "$TMP_DIR/dst"
printf 'new\n' >"$TMP_DIR/src/new"
printf 'old\n' >"$TMP_DIR/dst/keep"
# 强制 cp 分支；未授权时 mkdir/cp/rm/rsync 都不得执行。
have_cmd() { return 1; }
mkdir() { printf 'mkdir\n' >>"$TMP_DIR/writes"; command mkdir "$@"; }
cp() { printf 'cp\n' >>"$TMP_DIR/writes"; command cp "$@"; }
rm() { printf 'rm\n' >>"$TMP_DIR/writes"; command rm "$@"; }
rsync() { printf 'rsync\n' >>"$TMP_DIR/writes"; command rsync "$@"; }
rc=0
sync_dir "$TMP_DIR/src" "$TMP_DIR/dst" </dev/null || rc=$?
[[ "$rc" == 3 && "$(cat "$TMP_DIR/dst/keep")" == old ]] || fail '未授权目录同步必须返回 3 并保留目标'
[[ ! -e "$TMP_DIR/writes" ]] || fail '目录授权检查必须先于一切写操作'
unset -f mkdir cp rm rsync
IO_CONFLICT_MODE=skip_all
rc=0
sync_dir "$TMP_DIR/src" "$TMP_DIR/dst" </dev/null || rc=$?
[[ "$rc" == 1 && -f "$TMP_DIR/dst/keep" && ! -e "$TMP_DIR/dst/new" ]] || fail '目录 skip_all 必须返回 1 并保留目标'
unset IO_CONFLICT_MODE
IO_FORCE=1 sync_dir "$TMP_DIR/src" "$TMP_DIR/dst" </dev/null
[[ -f "$TMP_DIR/dst/new" && ! -e "$TMP_DIR/dst/keep" ]] || fail '授权 cp 同步应保持原有整树替换语义'
IO_CONFLICT_MODE=overwrite_all
sync_dir "$TMP_DIR/src" "$TMP_DIR/dst" </dev/null
unset IO_CONFLICT_MODE
sync_dir "$TMP_DIR/src" "$TMP_DIR/new/dst" </dev/null
[[ -f "$TMP_DIR/new/dst/new" ]] || fail '目录新目标应允许同步'
IO_DRY_RUN=1 sync_dir "$TMP_DIR/src" "$TMP_DIR/preview/dst" </dev/null
[[ ! -e "$TMP_DIR/preview" ]] || fail '目录 dry-run 不可创建目录'
rc=0
(io_should_overwrite() { return 2; }; sync_dir "$TMP_DIR/src" "$TMP_DIR/dst") || rc=$?
[[ "$rc" == 130 ]] || fail '目录取消决策 2 必须转换为 130'
# 验证 rsync 分支也执行相同授权，且保留调用参数。
have_cmd() { [[ "$1" == rsync ]]; }
rsync() {
  [[ "${1:-}" != --version ]] || { printf 'rsync version test\n'; return; }
  printf '%s\n' "$@" >"$TMP_DIR/rsync-args"
}
rc=0
sync_dir "$TMP_DIR/src" "$TMP_DIR/dst" </dev/null || rc=$?
[[ "$rc" == 3 && ! -e "$TMP_DIR/rsync-args" ]] || fail 'rsync 分支不得绕过授权'
IO_FORCE=1 sync_dir "$TMP_DIR/src" "$TMP_DIR/dst" --exclude tests </dev/null
rg --fixed-strings --quiet -- --delete "$TMP_DIR/rsync-args" || fail 'rsync 丢失 --delete'
rg --fixed-strings --quiet -- --exclude "$TMP_DIR/rsync-args" || fail 'rsync 丢失 --exclude'
assert_contains tests "$TMP_DIR/rsync-args"
pass '目录同步先授权再写入，rsync/cp 授权替换语义保持'
