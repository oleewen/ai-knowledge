#!/usr/bin/env bash
# 空列表后追加 child 不是有效登记；不得把歧义 YAML 当作可修复关系。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
cp "$SRC/docs/knowledge-links.yaml" "$TMP_DIR/list"
printf 'links: []\n' > "$SRC/docs/knowledge-links.yaml"
sed '1,2d' "$TMP_DIR/list" >> "$SRC/docs/knowledge-links.yaml"
snapshot_pair > "$TMP_DIR/before"
for action in check repair; do
  if run_link "--$action" --target "$TGT" > "$TMP_DIR/out" 2>&1; then fail "$action 接受歧义空列表后追加 child"; fi
  snapshot_pair > "$TMP_DIR/after"
  cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail "$action 修改了歧义清单仓库"
done
pass '歧义清单拒绝且零写入'
