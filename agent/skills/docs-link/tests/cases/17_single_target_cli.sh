#!/usr/bin/env bash
# 重复 target、空 name、unlink rewrite 和子目录 cwd 不得静默执行。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
snapshot_pair > "$TMP_DIR/before"
for scenario in duplicate empty-name unlink-http subdirectory; do
  case "$scenario" in
    duplicate) args=(--link --target "$TGT" --path "$TGT") ;;
    empty-name) args=(--link --target "$TGT" --app-name=) ;;
    unlink-http) args=(--unlink --target "$TGT" --rewrite-http) ;;
    subdirectory) args=(--link --target "$TGT"); SRC="$SRC/docs" ;;
  esac
  if run_link "${args[@]}" > "$TMP_DIR/out" 2>&1; then
    fail "$scenario 应拒绝"
  fi
  [[ "$scenario" != subdirectory ]] || SRC="$(dirname "$SRC")"
  snapshot_pair > "$TMP_DIR/after"
  cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail "$scenario 修改了仓库"
done
pass 'CLI 拒绝歧义参数与错误 cwd'
