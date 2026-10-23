#!/usr/bin/env bash
# 缺 source remote 或清单必填字段时，预览与实跑均拒绝且不变更树。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
git -C "$SRC" remote remove origin
for problem in source-remote target-entry; do
  if [[ "$problem" == target-entry ]]; then
    git -C "$SRC" remote add origin https://github.com/example/source.git
    cat > "$TGT/docs/knowledge-links.yaml" <<'EOF'
links:
  - type: meta
    path: "${WORK_SPACE}/meta"
    dir: "application"
EOF
  fi
  for mode in dry apply; do
    args=(); [[ "$mode" == apply ]] || args+=(--dry-run)
    snapshot_pair > "$TMP_DIR/before"
    if run_link --link --target "$TGT" "${args[@]}" > "$TMP_DIR/out" 2>&1; then
      fail "$problem/$mode 应失败"
    fi
    snapshot_pair > "$TMP_DIR/after"
    cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail "$problem/$mode 失败前已修改仓库"
  done
done
pass '双边必填字段在写入前校验'
