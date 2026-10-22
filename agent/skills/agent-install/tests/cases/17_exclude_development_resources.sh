#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"
excluded=(
  skills/demo/tests/cases/check.sh
  skills/demo/evals/evals.json
  skills/demo/agents/grader.md
  skills/demo/scripts/__pycache__/run.pyc
  skills/demo/scripts/run.pyc
  scripts/tests/run.sh
  scripts/test-core.sh
)
retained=(skills/demo/scripts/validate-output.sh skills/demo/agents/openai.yaml scripts/lib/runtime.sh)
for item in "${excluded[@]}" "${retained[@]}"; do
  mkdir -p "$FIXTURE/meta/agent/$(dirname "$item")"
  printf 'payload\n' >"$FIXTURE/meta/agent/$item"
done
ln -s demo "$FIXTURE/meta/agent/skills/linked-demo"

# Exercise both rsync and the cp fallback, including upgrades from an unfiltered tree.
mkdir -p "$FIXTURE/bin"
for tool in dirname basename date mkdir cp mv rm ln readlink find sed tr cat rg; do
  ln -s "$(command -v "$tool")" "$FIXTURE/bin/$tool"
done
original_path="$PATH"
for mode in native fallback; do
  for phase in fresh upgrade; do
    home_dir="$FIXTURE/$mode-$phase"
    mkdir -p "$home_dir"
    mkdir -p "$home_dir/.claude/scripts" "$home_dir/private-tests"
    printf 'IDE-owned\n' >"$home_dir/.claude/scripts/test-core.sh"
    ln -s "$home_dir/private-tests" "$home_dir/.claude/scripts/tests"
    if [[ "$phase" == upgrade ]]; then
      mkdir -p "$home_dir/.agents" "$home_dir/.codex/scripts" "$home_dir/.agents/skills/third-party/tests"
      cp -R "$FIXTURE/meta/agent/." "$home_dir/.agents/"
      printf 'private\n' >"$home_dir/.agents/skills/third-party/tests/private.sh"
      mkdir -p "$home_dir/.agents/rules/tests" "$home_dir/.codex/rules"
      printf 'private\n' >"$home_dir/.agents/rules/tests/private.sh"
      ln -s "$home_dir/.agents/rules/tests" "$home_dir/.codex/rules/tests"
      mkdir -p "$home_dir/.agents/hooks/tests" "$home_dir/.codex/hooks"
      printf 'obsolete\n' >"$home_dir/.agents/hooks/tests/old.sh"
      ln -s "$home_dir/.agents/hooks/tests" "$home_dir/.codex/hooks/tests"
      ln -s "$home_dir/.agents/scripts/tests" "$home_dir/.codex/scripts/tests"
      ln -s "$home_dir/.agents/scripts/test-core.sh" "$home_dir/.codex/scripts/test-core.sh"
    fi
    if [[ "$mode" == fallback ]]; then export PATH="$FIXTURE/bin"; else export PATH="$original_path"; fi
    if [[ "$phase" == upgrade ]]; then
      run_agent_install "$home_dir" --meta "$FIXTURE/meta" --scope=r --agents=codex >"$home_dir/rules-only" 2>&1
      for item in "${excluded[@]}"; do assert_file_exists "$home_dir/.agents/$item"; done
    fi
    run_agent_install "$home_dir" --meta "$FIXTURE/meta" --scope=a --agents=codex,claude --dry-run >"$home_dir/preview" 2>&1
    if [[ "$phase" == upgrade ]]; then
      for item in "${excluded[@]}"; do assert_file_exists "$home_dir/.agents/$item"; done
      assert_symlink_points_to "$home_dir/.codex/scripts/tests" "$home_dir/.agents/scripts/tests"
    else
      assert_dir_not_exists "$home_dir/.agents"
    fi
    assert_not_contains "[dry-run] 链接: $home_dir/.codex/scripts/tests ->" "$home_dir/preview"
    run_agent_install "$home_dir" --meta "$FIXTURE/meta" --scope=a --agents=codex,claude >"$home_dir/out" 2>&1
    for item in "${excluded[@]}"; do assert_file_not_exists "$home_dir/.agents/$item"; done
    for item in "${retained[@]}"; do assert_file_exists "$home_dir/.agents/$item"; done
    # 旧目标可链接到已过滤的安装树兄弟目录；验证内容，而非强制改写这种链接。
    assert_file_exists "$home_dir/.agents/skills/linked-demo/scripts/validate-output.sh"
    assert_file_not_exists "$home_dir/.agents/skills/linked-demo/tests/cases/check.sh"
    [[ ! -e "$home_dir/.codex/scripts/tests" && ! -L "$home_dir/.codex/scripts/tests" ]] || fail '残留测试目录链接'
    [[ ! -e "$home_dir/.codex/scripts/test-core.sh" && ! -L "$home_dir/.codex/scripts/test-core.sh" ]] || fail '残留测试工具链接'
    [[ ! -e "$home_dir/.codex/hooks/tests" && ! -L "$home_dir/.codex/hooks/tests" ]] || fail '源端已移除的 hooks 测试目录残留链接'
    assert_contains 'IDE-owned' "$home_dir/.claude/scripts/test-core.sh"
    assert_symlink_points_to "$home_dir/.claude/scripts/tests" "$home_dir/private-tests"
    if [[ "$phase" == upgrade ]]; then
      assert_file_exists "$home_dir/.agents/skills/third-party/tests/private.sh"
      assert_file_exists "$home_dir/.agents/rules/tests/private.sh"
      assert_symlink_points_to "$home_dir/.codex/rules/tests" "$home_dir/.agents/rules/tests"
    fi
  done
done
export PATH="$original_path"
for item in "${excluded[@]}"; do assert_file_exists "$FIXTURE/meta/agent/$item"; done
pass '首次安装与升级排除研发测试资源；预览只读、两种复制路径一致、保留运行时校验与第三方资源'
