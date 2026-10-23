#!/usr/bin/env bash
# knowledge 内文件软链不能让显式 HTTP 改写越过目标文档目录。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
cat > "$TGT/docs/knowledge-links.yaml" <<'EOF'
links:
  - type: parent
    repository: "https://github.com/example/old.git"
    path: "${WORK_SPACE}/old"
    dir: "docs"
    name: "old"
    label: "old"
EOF
mkdir -p "$TGT/docs/knowledge/business"
printf '[BD-X](https://github.com/example/old/blob/main/docs/knowledge/business/BD-X.md)\n' > "$TMP_DIR/external.md"
ln -s "$TMP_DIR/external.md" "$TGT/docs/knowledge/business/BD-X.md"
cp "$TMP_DIR/external.md" "$TMP_DIR/external-before"
snapshot_pair > "$TMP_DIR/before"
for mode in dry apply; do
  args=(); [[ "$mode" == apply ]] || args+=(--dry-run)
  if run_link --link --target "$TGT" --rewrite-http "${args[@]}" > "$TMP_DIR/out" 2>&1; then
    fail 'HTTP 计划应拒绝 knowledge 文件越界软链'
  fi
  snapshot_pair > "$TMP_DIR/after"
  cmp "$TMP_DIR/before" "$TMP_DIR/after"
  cmp "$TMP_DIR/external-before" "$TMP_DIR/external.md"
done
pass 'HTTP 改写拒绝越界文件软链'
