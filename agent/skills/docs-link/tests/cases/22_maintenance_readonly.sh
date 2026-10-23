#!/usr/bin/env bash
# check、修复预览与正确相对链不得改 YAML、正文或 Git index。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
slot="$SRC/docs/application-slots/application-target"
rm "$slot"
ln -s ../../../target/docs "$slot"
printf 'business text\n' > "$TGT/docs/body.md"
# 真实 index 和 staged 内容可检测意外 git add/reset。
git -C "$SRC" add .
git -C "$TGT" add .
snapshot_pair > "$TMP_DIR/before"
run_link --check > "$TMP_DIR/out" 2>&1 || { cat "$TMP_DIR/out"; fail '有效登记全量 check 应成功'; }
run_link --check --target "$TGT" >> "$TMP_DIR/out" 2>&1
run_link --repair --target https://github.com/example/target.git --dry-run >> "$TMP_DIR/out" 2>&1
run_link --repair --target "$TGT" >> "$TMP_DIR/out" 2>&1
snapshot_pair > "$TMP_DIR/after"
cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail '只读检查或正确相对链被修改'
pass '检查和正确相对链保持两仓及 Git index 原样'
