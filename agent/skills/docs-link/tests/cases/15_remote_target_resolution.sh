#!/usr/bin/env bash
# 已登记 remote 必须解析存储的本地 path，以便双边 link/unlink。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
snapshot_pair > "$TMP_DIR/before"
run_link --link --target https://github.com/example/target.git --dry-run > "$TMP_DIR/out" 2>&1 \
  || fail '已登记 URL 不能预览 link'
snapshot_pair > "$TMP_DIR/after"
cmp "$TMP_DIR/before" "$TMP_DIR/after"
assert_contains "$TGT/docs/knowledge-links.yaml" "$TMP_DIR/out"
run_link --unlink --target https://github.com/example/target.git > "$TMP_DIR/out" 2>&1
assert_not_contains 'type: parent' "$TGT/docs/knowledge-links.yaml"
[[ ! -L "$SRC/docs/application-slots/application-target" ]] || fail 'URL unlink 未移除槽位'
pass 'URL 通过登记 path 操作双边'
