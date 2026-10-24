#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
mkdir -p "$TMP_DIR/meta/application" "$TMP_DIR/bin"
git -C "$TMP_DIR/meta" init -q
git -C "$TMP_DIR/meta" remote add origin https://example.com/meta.git
printf '[rule](agent/rules/example.md)\n' >"$TMP_DIR/meta/application/README.md"
real_perl="$(command -v perl)"
cat >"$TMP_DIR/bin/perl" <<'SH'
#!/bin/sh
case "$REWRITE_FAILURE_MODE:$2" in
  path:-i|note:-e) printf 'injected-rewrite-failure\n' >&2; exit 73 ;;
esac
exec "$REAL_PERL" "$@"
SH
chmod +x "$TMP_DIR/bin/perl"
for mode in path note; do
  project="$TMP_DIR/$mode-project"
  mkdir -p "$project/docs"
  printf 'preserve\n' >"$project/docs/sentinel"
  status=0
  PATH="$TMP_DIR/bin:$PATH" REAL_PERL="$real_perl" REWRITE_FAILURE_MODE="$mode" \
    "$BASH" "$DOCS_INSTALL_SCRIPT" --meta "$TMP_DIR/meta" --target "$project/docs" --force >"$TMP_DIR/$mode.out" 2>&1 || status=$?
  [[ "$status" == 73 ]] || fail "$mode 改写失败须传播退出码 73，实际 $status"
  assert_not_contains '完成：docs-install' "$TMP_DIR/$mode.out"
  assert_contains '初始化未完成' "$TMP_DIR/$mode.out"
  assert_contains 'injected-rewrite-failure' "$TMP_DIR/$mode.out"
  assert_file_exists "$project/.docsconfig"
  backup="$(find "$project/.docs-init" -name sentinel -print -quit)"
  [[ -n "$backup" ]] || fail '失败后原内容备份丢失'
  assert_contains 'preserve' "$backup"
done
pass '路径改写或 README 注记失败均传播原退出码，保留部分产物与原内容备份'
