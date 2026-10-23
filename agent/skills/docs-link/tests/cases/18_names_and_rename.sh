#!/usr/bin/env bash
# 三种层级均接受名称；重命名移除旧软链，不能占用另一 child 的 name。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
for pair in 'company solution' 'solution system' 'system application'; do
  read -r source_kind target_kind <<< "$pair"
  fixture_pair "$source_kind" "$target_kind"
  run_link --link --target "$TGT" --app-name PAY-System > "$TMP_DIR/out" 2>&1
  assert_symlink_points_to "$SRC/docs/$target_kind-slots/$target_kind-pay-system" "$TGT/docs"
  run_link --link --target "$TGT" --app-name billing >> "$TMP_DIR/out" 2>&1
  [[ ! -L "$SRC/docs/$target_kind-slots/$target_kind-pay-system" ]] || fail '改名遗留旧槽位'
  assert_symlink_points_to "$SRC/docs/$target_kind-slots/$target_kind-billing" "$TGT/docs"
  cat >> "$SRC/docs/knowledge-links.yaml" <<'EOF'
  - type: child
    repository: "https://example.com/other.git"
    path: "${WORK_SPACE}/other"
    dir: "docs"
    name: "occupied"
    label: "other"
EOF
  snapshot_pair > "$TMP_DIR/before"
  if run_link --link --target "$TGT" --app-name occupied > "$TMP_DIR/out" 2>&1; then
    fail '不应占用另一 child 的名称'
  fi
  snapshot_pair > "$TMP_DIR/after"
  cmp "$TMP_DIR/before" "$TMP_DIR/after"
  rm -rf "$TMP_DIR"
done
pass '三层名称、改名与冲突保护'
