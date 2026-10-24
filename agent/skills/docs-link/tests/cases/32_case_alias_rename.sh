#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
slots="$SRC/docs/application-slots"
mv "$slots/application-target" "$slots/temporary-slot"
mv "$slots/temporary-slot" "$slots/application-TARGET"
sed 's/name: "target"/name: "TARGET"/' "$SRC/docs/knowledge-links.yaml" > "$TMP_DIR/list"
cp "$TMP_DIR/list" "$SRC/docs/knowledge-links.yaml"
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
assert_symlink_points_to "$slots/application-target" "$TGT/docs"
python3 -B - "$slots" <<'PY'
import os, sys
names = os.listdir(sys.argv[1])
assert 'application-target' in names and 'application-TARGET' not in names, names
PY
assert_contains 'name: "target"' "$SRC/docs/knowledge-links.yaml"
run_link --check --target "$TGT" > "$TMP_DIR/out" 2>&1
pass '大小写名称规范化后槽位与双边关系仍有效'
