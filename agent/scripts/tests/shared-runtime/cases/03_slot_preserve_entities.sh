#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
source "$SCRIPTS_ROOT/lib/slot-softlink.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/target" "$TMP_DIR/other"
# 每个 API 独立夹具；聚合失败，确保每条危险路径均在 RED 中实际执行。
failed=0
for operation in slot_migrate_real_slot_dir slot_ensure_slot_symlink slot_remove_slot_path; do
  for kind in directory file; do
    slot="$TMP_DIR/$operation-$kind"
    if [[ "$kind" == directory ]]; then
      mkdir -p "$slot"
      printf 'preserve\n' >"$slot/sentinel"
    else
      printf 'preserve\n' >"$slot"
    fi
    rc=0
    "$operation" "$slot" "$TMP_DIR/target" >"$TMP_DIR/out" 2>"$TMP_DIR/err" || rc=$?
    preserved=0
    if [[ "$kind" == directory && -d "$slot" && ! -L "$slot" && -f "$slot/sentinel" ]]; then
      [[ "$(cat "$slot/sentinel")" != preserve ]] || preserved=1
    elif [[ "$kind" == file && -f "$slot" && ! -L "$slot" ]]; then
      [[ "$(cat "$slot")" != preserve ]] || preserved=1
    fi
    if [[ "$rc" == 0 || "$preserved" != 1 || ! -s "$TMP_DIR/err" ]]; then
      printf 'FAIL: %s 必须报错并保留 %s\n' "$operation" "$kind" >&2
      failed=$((failed + 1))
    fi
  done
done
((failed == 0)) || fail "$failed 条 slot 实体保留断言失败"
slot_remove_slot_path "$TMP_DIR/missing"
slot_ensure_slot_symlink "$TMP_DIR/new/slot" "$TMP_DIR/target" >"$TMP_DIR/out"
assert_symlink_points_to "$TMP_DIR/new/slot" "$TMP_DIR/target"
[[ "$(cat "$TMP_DIR/out")" == link-fix ]] || fail '新软链 action 必须兼容'
slot_migrate_real_slot_dir "$TMP_DIR/new/slot"
assert_symlink_points_to "$TMP_DIR/new/slot" "$TMP_DIR/target"
slot_ensure_slot_symlink "$TMP_DIR/new/slot" "$TMP_DIR/target" >"$TMP_DIR/out"
[[ ! -s "$TMP_DIR/out" ]] || fail '正确软链不应报告动作'
slot_ensure_slot_symlink "$TMP_DIR/new/slot" "$TMP_DIR/other" >"$TMP_DIR/out"
assert_symlink_points_to "$TMP_DIR/new/slot" "$TMP_DIR/other"
slot_remove_slot_path "$TMP_DIR/new/slot"
[[ ! -L "$TMP_DIR/new/slot" && -d "$TMP_DIR/other" ]] || fail 'remove 仅移除软链'
ln -s "$TMP_DIR/missing-target" "$TMP_DIR/dangling"
slot_remove_slot_path "$TMP_DIR/dangling"
[[ ! -L "$TMP_DIR/dangling" ]] || fail '应允许移除悬空软链'
pass '旧 slot API 保留实体，软链可创建/修复/移除，缺路径删除幂等'
