#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
META="$TMP_DIR/meta"
mkdir -p "$META/application"
git -C "$META" init -q
git -C "$META" remote add origin https://example.com/meta.git
printf 'preserve\n' >"$META/application/sentinel"
ln -s "$META/application" "$TMP_DIR/source-alias"

assert_boundary_rejected() {
  local target="$1" meta="$2" flag
  for flag in --dry-run --force; do
    if "$BASH" "$DOCS_INSTALL_SCRIPT" --meta "$meta" --target "$target" -r "$flag" >"$TMP_DIR/out" 2>&1; then
      fail "同 inode 的源/目标边界必须拒绝: $target ($flag)"
    fi
    assert_file_exists "$META/application/sentinel"
    [[ ! -e "$META/.docs-init" ]] || fail '边界拒绝之前不得备份源目录'
  done
}

# 任何文件系统均验证同 inode 的软链别名，以及别名下未存在的后代。
assert_boundary_rejected "$TMP_DIR/source-alias" "$META"
assert_boundary_rejected "$TMP_DIR/source-alias/not-created/docs" "$META"

if [[ -d "$META/APPLICATION" && "$META/application" -ef "$META/APPLICATION" ]]; then
  assert_boundary_rejected "$META/APPLICATION" "$META"
  assert_boundary_rejected "$META/APPLICATION/not-created/docs" "$META"
  mkdir -p "$TMP_DIR/external-templates" "$TMP_DIR/container/meta"
  git -C "$TMP_DIR/container/meta" init -q
  git -C "$TMP_DIR/container/meta" remote add origin https://example.com/meta.git
  ln -s "$TMP_DIR/external-templates" "$TMP_DIR/container/meta/application"
  assert_boundary_rejected "$TMP_DIR/CONTAINER" "$TMP_DIR/container/meta"
  assert_file_exists "$TMP_DIR/container/meta/.git/config"
  [[ ! -e "$TMP_DIR/.docs-init" ]] || fail '元库祖先大小写别名不得触发备份'
else
  printf 'SKIP: 文件系统区分大小写，大小写别名分支不适用\n'
fi
pass '按 inode 校验源/目标和元库根的真实包含关系'
