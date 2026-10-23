#!/usr/bin/env bash
# repair 仅修改选中槽位，dry-run 没有目录或内容副作用。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
slot="$SRC/docs/application-slots/application-target"
rm "$slot"
rmdir "$(dirname "$slot")"
for state in absent dangling wrong; do
  if [[ "$state" != absent ]]; then
    mkdir -p "$(dirname "$slot")"
    [[ ! -L "$slot" ]] || rm "$slot"
    destination="$TMP_DIR/missing"
    [[ "$state" != wrong ]] || destination="$SRC/docs"
    ln -s "$destination" "$slot"
  fi
  snapshot_pair > "$TMP_DIR/before"
  if run_link --check --target "$TGT" > "$TMP_DIR/out" 2>&1; then fail "$state check 应失败"; fi
  run_link --repair --target "$TGT" --dry-run > "$TMP_DIR/out" 2>&1 || { cat "$TMP_DIR/out"; fail "$state 应可预览修复"; }
  snapshot_pair > "$TMP_DIR/after"
  cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail "$state 预览有副作用"
  cp "$SRC/docs/knowledge-links.yaml" "$TMP_DIR/source-before"
  cp "$TGT/docs/knowledge-links.yaml" "$TMP_DIR/target-before"
  run_link --repair --target "$TGT" > "$TMP_DIR/out" 2>&1
  assert_symlink_points_to "$slot" "$TGT/docs"
  snapshot_pair > "$TMP_DIR/after-repair"
  python3 -B - "$TMP_DIR/before" "$TMP_DIR/after-repair" "$SRC" <<'CHECK'
import json, sys
before, after = (json.load(open(path)) for path in sys.argv[1:3])
allowed = {'docs/application-slots', 'docs/application-slots/application-target'}
def immutable(rows):
    return [row for row in rows if not (row[0] == sys.argv[3] and row[1] in allowed)]
assert immutable(before) == immutable(after), 'repair changed data outside the selected slot'
CHECK
  cmp "$TMP_DIR/source-before" "$SRC/docs/knowledge-links.yaml"
  cmp "$TMP_DIR/target-before" "$TGT/docs/knowledge-links.yaml"
  run_link --check --target "$TGT" >> "$TMP_DIR/out" 2>&1
done
pass '缺失、悬空和错指槽位可修复，预览不写入'
