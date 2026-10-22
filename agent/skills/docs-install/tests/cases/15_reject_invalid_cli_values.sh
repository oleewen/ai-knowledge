#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
failures=0
for flag in target scope type mode meta; do
  for form in missing empty; do
    project="$TMP_DIR/$flag-$form"
    mkdir -p "$project/docs"
    args=("--$flag" --dry-run)
    [[ "$form" != empty ]] || args=("--$flag=" --dry-run)
    if (cd "$project" && "$BASH" "$DOCS_INSTALL_SCRIPT" --scope=config --target "$project/docs" "${args[@]}") >"$TMP_DIR/out" 2>&1; then
      printf 'unexpected success: %s %s\n' "$flag" "$form" >&2
      ((++failures))
    fi
    [[ ! -e "$project/.docsconfig" ]] || { printf 'unexpected config write: %s %s\n' "$flag" "$form" >&2; ((++failures)); }
  done
done
mkdir -p "$TMP_DIR/mode/docs"
if "$BASH" "$DOCS_INSTALL_SCRIPT" --scope=config --mode=invalid --target "$TMP_DIR/mode/docs" --dry-run >"$TMP_DIR/out" 2>&1; then
  printf 'unexpected success: invalid mode\n' >&2
  ((++failures))
fi
[[ "$failures" -eq 0 ]] || fail "参数错误必须在写入前拒绝（$failures 项）"
pass '缺失值、空等号值和未知 mode 均拒绝，后续 flag 不被吞掉'
