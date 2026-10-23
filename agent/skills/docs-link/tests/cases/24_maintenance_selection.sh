#!/usr/bin/env bash
# 全量首项失败仍检查后项；单项不因其他失联项阻塞，不凭相同 remote 换仓。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
cp "$SRC/docs/knowledge-links.yaml" "$TMP_DIR/valid"
cat > "$SRC/docs/knowledge-links.yaml" <<'YAML'
links:
  - type: child
    repository: "https://example.com/offline.git"
    path: "${WORK_SPACE}/offline"
    dir: "docs"
    name: "offline"
YAML
sed '1,2d' "$TMP_DIR/valid" >> "$SRC/docs/knowledge-links.yaml"
snapshot_pair > "$TMP_DIR/before"
if run_link --check > "$TMP_DIR/out" 2>&1; then fail '全量不能忽略失联登记'; fi
assert_contains 'offline' "$TMP_DIR/out"
assert_contains 'application-target' "$TMP_DIR/out"
run_link --check --target "$TGT" > "$TMP_DIR/out" 2>&1 || fail '单选受未选失联项影响'
run_link --repair --target "$TGT" > "$TMP_DIR/out" 2>&1
snapshot_pair > "$TMP_DIR/after"
cmp "$TMP_DIR/before" "$TMP_DIR/after"
# 即使未选槽位悬空，修复也只写选中槽位。
slot="$SRC/docs/application-slots/application-target"
other_slot="$SRC/docs/application-slots/application-offline"
ln -s "$TMP_DIR/never-present" "$other_slot"
rm "$slot"
run_link --repair --target "$TGT" > "$TMP_DIR/out" 2>&1
assert_symlink_points_to "$slot" "$TGT/docs"
[[ "$(readlink "$other_slot")" == "$TMP_DIR/never-present" ]] || fail '修复触碰了未选槽位'
cp -R "$TGT" "$TMP_DIR/work space/other"
if run_link --repair --target "$TMP_DIR/work space/other" > "$TMP_DIR/out" 2>&1; then fail '相同 remote 的未登记 checkout 不可替代登记 path'; fi
# 无法展开的坏 path 也必须逐项收集，不在全量入口首错退出。
sed 's@${WORK_SPACE}/offline@${WORK_SPACE}/../../escape@' "$SRC/docs/knowledge-links.yaml" > "$TMP_DIR/list"
cp "$TMP_DIR/list" "$SRC/docs/knowledge-links.yaml"
if run_link --check > "$TMP_DIR/out" 2>&1; then fail '全量必须拒绝越界 path'; fi
assert_contains 'application-target' "$TMP_DIR/out"
run_link --check --target "$TGT" > "$TMP_DIR/out" 2>&1 || fail '单选应隔离未选项的 path 错误'
pass '逐项汇总、单选隔离与登记 path 精确定位'
