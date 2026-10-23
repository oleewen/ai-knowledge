#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
source "$SCRIPTS_ROOT/lib/log-io.sh"
declare -A CFG=()
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
printf 'new\n' >"$TMP_DIR/src"
printf 'old\n' >"$TMP_DIR/dst"
IO_CONFLICT_MODE=skip_all
rc=0
io_copy_file "$TMP_DIR/src" "$TMP_DIR/dst" 2>"$TMP_DIR/err" || rc=$?
[[ "$rc" -eq 1 && "$(cat "$TMP_DIR/dst")" == old ]] || fail 'skip 必须返回 1 且保留目标'
[[ "$(cat "$TMP_DIR/err")" == "[skip] $TMP_DIR/dst" ]] || fail 'skip 日志漂移'
IO_FORCE=1
io_copy_file "$TMP_DIR/src" "$TMP_DIR/dst"
cmp "$TMP_DIR/src" "$TMP_DIR/dst" || fail 'force 未覆盖'
unset IO_FORCE
for setting in DRY_RUN IO_DRY_RUN; do
  (
    unset DRY_RUN IO_DRY_RUN
    printf -v "$setting" '%s' 1
    io_copy_file "$TMP_DIR/src" "$TMP_DIR/$setting/file" 2>"$TMP_DIR/err"
    [[ ! -e "$TMP_DIR/$setting" ]] || fail "$setting 写入目标"
    assert_contains '[dry-run] 拷贝:' "$TMP_DIR/err"
  )
done
(
  declare -A CFG=([dry_run]=1)
  ensure_dir "$TMP_DIR/cfg-dir" 2>"$TMP_DIR/err"
  [[ ! -d "$TMP_DIR/cfg-dir" ]] || fail 'CFG[dry_run] 创建目录'
)
# 真实终端 Esc 应由决策层返回 2，再由 copy 层转为 130。
python3 - "$BASH" "$SCRIPTS_ROOT/lib/log-io.sh" "$TMP_DIR" <<'PY'
import os, pty, select, subprocess, sys, time, tty
master, slave = pty.openpty()
tty.setraw(slave)
script = 'source "$1"; declare -A CFG=(); io_copy_file "$2/src" "$2/dst"'
proc = subprocess.Popen([sys.argv[1], '-c', script, 'io-cancel', *sys.argv[2:]], stdin=slave, stdout=slave, stderr=slave)
os.close(slave)
output = b''
try:
    deadline = time.monotonic() + 5
    while b'Esc' not in output and time.monotonic() < deadline:
        if select.select([master], [], [], 0.1)[0]:
            output += os.read(master, 4096)
    if b'Esc' not in output:
        raise SystemExit('FAIL: 未出现覆盖提示')
    os.write(master, b'\x1b')
    if proc.wait(timeout=5) != 130:
        raise SystemExit('FAIL: Esc 未返回 130')
finally:
    if proc.poll() is None:
        proc.kill()
        proc.wait()
    os.close(master)
PY
pass 'IO skip/force/dry-run 与 Esc 130 保持'
