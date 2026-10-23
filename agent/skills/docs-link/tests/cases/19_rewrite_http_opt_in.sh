#!/usr/bin/env bash
# HTTP 改写只在显式 link 时发生；预览不能产生正文变化或 Python 缓存。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
cat > "$TMP_DIR/old-parent" <<'EOF'
links:
  - type: parent
    repository: "https://github.com/example/old.git"
    path: "${WORK_SPACE}/old"
    dir: "docs"
    name: "old"
    label: "old"
EOF
cp "$TMP_DIR/old-parent" "$TGT/docs/knowledge-links.yaml"
mkdir -p "$TGT/docs/knowledge/business"
old='https://github.com/example/old/blob/main/docs/knowledge/business/BD-X.md'
new='https://github.com/example/source/blob/main/docs/knowledge/business/BD-X.md'
printf '[BD-X](%s)\n' "$old" > "$TGT/docs/knowledge/business/BD-X.md"
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
assert_contains "$old" "$TGT/docs/knowledge/business/BD-X.md"
cp "$TMP_DIR/old-parent" "$TGT/docs/knowledge-links.yaml"
snapshot_pair > "$TMP_DIR/before"
run_link --link --target "$TGT" --rewrite-http --dry-run > "$TMP_DIR/out" 2>&1
snapshot_pair > "$TMP_DIR/after"
cmp "$TMP_DIR/before" "$TMP_DIR/after"
run_link --link --target "$TGT" --rewrite-http > "$TMP_DIR/out" 2>&1
assert_contains "$new" "$TGT/docs/knowledge/business/BD-X.md"
assert_not_contains "$old" "$TGT/docs/knowledge/business/BD-X.md"
pass 'HTTP 默认不改，显式预览只读，实跑正确改写'
