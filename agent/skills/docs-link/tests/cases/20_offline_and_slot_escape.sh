#!/usr/bin/env bash
# 离线注销可完成源侧；槽位父目录越界不能改任何仓库或外部数据。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
mkdir "$TMP_DIR/outside"
printf 'keep\n' > "$TMP_DIR/outside/keep"
ln -s "$TMP_DIR/outside" "$SRC/docs/application-slots"
snapshot_pair > "$TMP_DIR/before"
if run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1; then fail '槽位父目录软链应拒绝'; fi
snapshot_pair > "$TMP_DIR/after"
cmp "$TMP_DIR/before" "$TMP_DIR/after"
[[ "$(cat "$TMP_DIR/outside/keep")" == keep ]] || fail '外部数据被改'
rm "$SRC/docs/application-slots"
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
mv "$TGT" "$TMP_DIR/offline-target"
run_link --unlink --target https://github.com/example/target.git > "$TMP_DIR/out" 2>&1
assert_not_contains 'type: child' "$SRC/docs/knowledge-links.yaml"
[[ ! -L "$SRC/docs/application-slots/application-target" ]] || fail '离线注销残留软链'
assert_contains '目标侧未更新' "$TMP_DIR/out"
assert_contains 'type: parent' "$TMP_DIR/offline-target/docs/knowledge-links.yaml"
pass '离线注销明确结果边界，拒绝槽位父目录越界'
