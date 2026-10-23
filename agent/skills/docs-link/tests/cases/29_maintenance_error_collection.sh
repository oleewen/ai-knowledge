#!/usr/bin/env bash
# 首项重复/旧字段只令该项失败，后续正常 child 仍检查并汇总。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
cp "$SRC/docs/knowledge-links.yaml" "$TMP_DIR/valid"
for problem in duplicate legacy; do
  cat > "$SRC/docs/knowledge-links.yaml" <<'YAML'
links:
  - type: child
    repository: "https://example.com/offline.git"
    path: "${WORK_SPACE}/offline"
    dir: "docs"
    name: "offline"
YAML
  if [[ "$problem" == duplicate ]]; then
    printf '    dir: "docs"\n' >> "$SRC/docs/knowledge-links.yaml"
  else
    printf '    app_name: "offline"\n' >> "$SRC/docs/knowledge-links.yaml"
  fi
  sed '1,2d' "$TMP_DIR/valid" >> "$SRC/docs/knowledge-links.yaml"
  snapshot_pair > "$TMP_DIR/before"
  if run_link --check > "$TMP_DIR/out" 2>&1; then fail "$problem 全量应非零"; fi
  assert_contains '[正常]' "$TMP_DIR/out"
  assert_contains 'child=2 成功=1 失败=1' "$TMP_DIR/out"
  if [[ "$problem" == duplicate ]]; then
    assert_contains '重复字段 dir' "$TMP_DIR/out"
  else
    assert_contains '旧字段 app_name' "$TMP_DIR/out"
  fi
  run_link --check --target "$TGT" > "$TMP_DIR/out" 2>&1 || fail "$problem 未选错误条目阻塞正常目标"
  snapshot_pair > "$TMP_DIR/after"
  cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail "$problem 检查修改了仓库"
done
pass '错误字段逐项报告，后续 child 正常检查且无副作用'
