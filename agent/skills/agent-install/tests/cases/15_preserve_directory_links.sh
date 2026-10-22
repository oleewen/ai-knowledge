#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"
printf 'new rule\n' >"$FIXTURE/meta/agent/rules/new.txt"

# 目录链接的两端是同一实体，不能把实体文件当作 IDE 冲突搬走。
for layout in absolute relative root; do
  sandbox="$FIXTURE/$layout"
  mkdir -p "$sandbox/.agents/rules"
  printf 'original\n' >"$sandbox/.agents/rules/item.txt"
  if [[ "$layout" == root ]]; then
    ln -s "$sandbox/.agents" "$sandbox/.codex"
    directory_link="$sandbox/.codex"
  else
    mkdir -p "$sandbox/.codex"
    destination="$sandbox/.agents/rules"
    [[ "$layout" != relative ]] || destination='../.agents/rules'
    ln -s "$destination" "$sandbox/.codex/rules"
    directory_link="$sandbox/.codex/rules"
  fi
  original_link="$(readlink "$directory_link")"
  run_agent_install "$sandbox" --meta "$FIXTURE/meta" --scope=r --agents=codex --dry-run >"$FIXTURE/preview" 2>&1
  assert_contains original "$sandbox/.agents/rules/item.txt"
  assert_not_contains '将备份' "$FIXTURE/preview"
  assert_not_contains "链接: $sandbox/.codex/rules/new.txt" "$FIXTURE/preview"
  assert_file_not_exists "$sandbox/.agents/rules/new.txt"
  for attempt in 1 2; do
    run_agent_install "$sandbox" --meta "$FIXTURE/meta" --scope=r --agents=codex >"$FIXTURE/out" 2>&1
    [[ ! -L "$sandbox/.agents/rules/item.txt" ]] || fail "实体文件不能变成软链: $layout"
    cmp "$FIXTURE/meta/agent/rules/item.txt" "$sandbox/.agents/rules/item.txt" || fail "实体文件内容错误: $layout"
    cmp "$FIXTURE/meta/agent/rules/new.txt" "$sandbox/.agents/rules/new.txt" || fail "新增文件内容错误: $layout"
    [[ "$(readlink "$directory_link")" == "$original_link" ]] || fail "应保留原目录软链: $layout"
    assert_dir_not_exists "$sandbox/.docs-init"
  done
done
pass "绝对、相对和 IDE 根目录链接均保留实体，预览和重入不搬移文件"
