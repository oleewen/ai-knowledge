#!/usr/bin/env bash
# 类型歧义不能把 child 隐藏为 meta，使缺槽检查误报成功。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
rm "$SRC/docs/application-slots/application-target"
printf '    type: meta\n' >> "$SRC/docs/knowledge-links.yaml"
snapshot_pair > "$TMP_DIR/before"
if run_link --check > "$TMP_DIR/out" 2>&1; then fail '重复 type 隐藏 child，检查误报成功'; fi
assert_contains '重复 type' "$TMP_DIR/out"
if run_link --repair --target "$TGT" > "$TMP_DIR/out" 2>&1; then fail '重复 type 不能用于修复'; fi
snapshot_pair > "$TMP_DIR/after"
cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail '类型歧义导致仓库变化'
pass '重复类型歧义被拒绝且不隐藏失败项'
