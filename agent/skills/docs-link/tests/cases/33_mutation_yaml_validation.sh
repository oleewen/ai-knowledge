#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
cp "$SRC/docs/knowledge-links.yaml" "$TMP_DIR/source-list"
cp "$TGT/docs/knowledge-links.yaml" "$TMP_DIR/target-list"
for side in source target; do
  cp "$TMP_DIR/source-list" "$SRC/docs/knowledge-links.yaml"
  cp "$TMP_DIR/target-list" "$TGT/docs/knowledge-links.yaml"
  file="$SRC/docs/knowledge-links.yaml"
  [[ "$side" == source ]] || file="$TGT/docs/knowledge-links.yaml"
  printf 'links: []\n' > "$file"
  sed '1,2d' "$TMP_DIR/$side-list" >> "$file"
  snapshot_pair > "$TMP_DIR/before"
  for action in link unlink; do
    for mode in preview apply; do
      args=("--$action" --target "$TGT")
      [[ "$mode" != preview ]] || args+=(--dry-run)
      if run_link "${args[@]}" > "$TMP_DIR/out" 2>&1; then fail "$side $action $mode 接受歧义清单"; fi
      snapshot_pair > "$TMP_DIR/after"
      cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail '非法清单被修改'
    done
  done
done
pass '两侧非法结构阻止 link/unlink 预览与写入'
