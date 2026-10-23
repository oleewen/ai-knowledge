#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"
mkdir -p "$FIXTURE/project/src" "$FIXTURE/source/agent-data" "$FIXTURE/old" "$FIXTURE/new"
printf 'WORK_SPACE=%s\n' "$FIXTURE/new" >"$FIXTURE/source/agent-data/configs"
printf 'REPO_DIR=project\nDOC_DIR=docs\nAGENT_ROOT=%s\nAGENT_DIR=agent-data\n' "$FIXTURE/source" >"$FIXTURE/project/.docsconfig"
cp "$FIXTURE/project/.docsconfig" "$FIXTURE/project-config.before"
cd "$FIXTURE/project/src"

home_dir="$FIXTURE/home"
mkdir -p "$home_dir/.agents"
printf 'WORK_SPACE=%s\n' "$FIXTURE/old" >"$home_dir/.agents/configs"
cp "$home_dir/.agents/configs" "$FIXTURE/global.before"
args=(--meta "$FIXTURE/meta" --scope=r --agents=codex --target "$FIXTURE/ide")

# 冲突实跑须在写 configs、安装资源和创建 IDE 目录之前拒绝。
if run_agent_install_infer_workspace "$home_dir" "${args[@]}" >"$FIXTURE/rejected" 2>&1; then
  fail '推断值与既有全局 WORK_SPACE 冲突时不得直接实跑'
fi
cmp -s "$FIXTURE/global.before" "$home_dir/.agents/configs" || fail '拒绝后全局配置被改写'
assert_dir_not_exists "$home_dir/.agents/rules"
assert_dir_not_exists "$FIXTURE/ide"

# 预览仍应完成并揭示冲突、两边的值及显式确认入口；不得落盘。
run_agent_install_infer_workspace "$home_dir" "${args[@]}" --dry-run >"$FIXTURE/preview" 2>&1
assert_contains "$FIXTURE/old" "$FIXTURE/preview"
assert_contains "$FIXTURE/new" "$FIXTURE/preview"
rg -q -F -- '--workspace' "$FIXTURE/preview" || fail '预览未给出显式工作区选择入口'
cmp -s "$FIXTURE/global.before" "$home_dir/.agents/configs" || fail '预览改写全局配置'
assert_dir_not_exists "$FIXTURE/ide"

# 确认后显式选择新值或保留旧值，都可按同一安装计划执行。
for selected in new old; do
  run_agent_install_infer_workspace "$home_dir" "${args[@]}" --workspace "$FIXTURE/$selected" >"$FIXTURE/explicit-$selected" 2>&1
  assert_contains "WORK_SPACE=$FIXTURE/$selected" "$home_dir/.agents/configs"
  assert_symlink_points_to "$FIXTURE/ide/.codex/rules/item.txt" "$home_dir/.agents/rules/item.txt"
done

# 全局值不存在或与推断值等价，不新增确认门槛。
for state in missing same; do
  home_dir="$FIXTURE/$state-home"
  mkdir -p "$home_dir/.agents"
  if [[ "$state" == same ]]; then
    printf 'WORK_SPACE=%s/\n' "$FIXTURE/new" >"$home_dir/.agents/configs"
  fi
  run_agent_install_infer_workspace "$home_dir" --meta "$FIXTURE/meta" --scope=r --agents=codex >"$FIXTURE/$state" 2>&1
  assert_contains "WORK_SPACE=$FIXTURE/new" "$home_dir/.agents/configs"
done
cmp -s "$FIXTURE/project-config.before" "$FIXTURE/project/.docsconfig" || fail '改写了工程配置'
assert_contains "WORK_SPACE=$FIXTURE/new" "$FIXTURE/source/agent-data/configs"
pass '推断冲突实跑零写入；预览揭示差异；显式选择、同值和首次安装可执行'
