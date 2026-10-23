#!/usr/bin/env bash
# 普通目录、被占用名称与越界槽位父目录必须在写前拒绝。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
mkdir -p "$SRC/docs/application-slots/application-target"
printf '用户文件\n' > "$SRC/docs/application-slots/application-target/keep.md"
for action in link unlink; do
  if [[ "$action" == unlink ]]; then
    cat > "$SRC/docs/knowledge-links.yaml" <<'EOF'
links:
  - type: child
    repository: "https://github.com/example/target.git"
    path: "${WORK_SPACE}/target"
    dir: "docs"
    name: "target"
    label: "target"
EOF
  fi
  snapshot_pair > "$TMP_DIR/before"
  if run_link "--$action" --target "$TGT" > "$TMP_DIR/out" 2>&1; then
    fail "$action 不应删除普通目录"
  fi
  snapshot_pair > "$TMP_DIR/after"
  cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail "$action 冲突时已修改仓库"
done
pass '槽位普通目录保留'
