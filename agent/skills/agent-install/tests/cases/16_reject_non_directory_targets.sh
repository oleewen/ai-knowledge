#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"
mkdir -p "$FIXTURE/.agents/rules"
printf 'original rule\n' >"$FIXTURE/.agents/rules/item.txt"
printf 'WORK_SPACE=/original/workspace\n' >"$FIXTURE/.agents/configs"
cp "$FIXTURE/.agents/configs" "$FIXTURE/configs.before"
cp "$FIXTURE/.agents/rules/item.txt" "$FIXTURE/rule.before"
printf 'not a directory\n' >"$FIXTURE/target-file"
ln -s "$FIXTURE/target-file" "$FIXTURE/file-link"
ln -s "$FIXTURE/missing" "$FIXTURE/dangling-link"

for target in "$FIXTURE/target-file" "$FIXTURE/target-file/new/project" "$FIXTURE/file-link" "$FIXTURE/dangling-link/project" "$FIXTURE/not-created/../target-file"; do
  for mode in preview install; do
    options=()
    [[ "$mode" != preview ]] || options+=(--dry-run)
    if run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=r --agents=codex --target "$target" "${options[@]}" >"$FIXTURE/out" 2>&1; then
      fail "无效 target 应在 $mode 阶段被拒绝: $target"
    fi
    cmp "$FIXTURE/configs.before" "$FIXTURE/.agents/configs" || fail '失败前改写了 configs'
    cmp "$FIXTURE/rule.before" "$FIXTURE/.agents/rules/item.txt" || fail '失败前改写了 rules'
    assert_not_contains '安装：' "$FIXTURE/out"
    assert_dir_not_exists "$FIXTURE/.codex"
  done
done

# 尚未创建的目录合法，不能因前置检查而拒绝首次安装。
run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=r --agents=codex --target "$FIXTURE/new/project" >"$FIXTURE/out" 2>&1
assert_symlink_points_to "$FIXTURE/new/project/.codex/rules/item.txt" "$FIXTURE/.agents/rules/item.txt"

# .. 必须沿现存软链的实际父目录解析，不能只对输入字符串消除路径段。
mkdir -p "$FIXTURE/physical/child" "$FIXTURE/alias-parent"
ln -s "$FIXTURE/physical/child" "$FIXTURE/alias-parent/link"
run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=r --agents=codex --target "$FIXTURE/alias-parent/link/../not-created/../project" >"$FIXTURE/out" 2>&1
assert_symlink_points_to "$FIXTURE/physical/project/.codex/rules/item.txt" "$FIXTURE/.agents/rules/item.txt"
assert_dir_not_exists "$FIXTURE/alias-parent/project"
pass "target 或祖先为文件/断链时预览与实跑均不写入；新目录可安装"
