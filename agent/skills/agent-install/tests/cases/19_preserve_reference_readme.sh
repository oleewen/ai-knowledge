#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"
retained=(
  skills/demo/references/README.md
  skills/demo/nested/references/README.md
  references/README.md
  references/nested/references/README.md
  references/references/README.md
)
excluded=(
  skills/demo/README.md
  skills/demo/nested/readme.md
  skills/demo/only-lower/references/readme.md
  skills/demo/references/README
  skills/demo/reference/README.md
  skills/demo/references/nested/README.md
  skills/demo/tests/references/README.md
  references/tests/README.md
  references/tests/references/README.md
)
for item in "${retained[@]}" "${excluded[@]}"; do
  mkdir -p "$FIXTURE/meta/agent/$(dirname "$item")"
  printf 'reference navigation\n' >"$FIXTURE/meta/agent/$item"
done

mkdir -p "$FIXTURE/bin"
for tool in dirname basename date mkdir cp mv rm ln readlink find sed tr cat rg; do
  ln -s "$(command -v "$tool")" "$FIXTURE/bin/$tool"
done
test_base_path="$PATH"
for mode in native fallback; do
  for phase in fresh upgrade; do
    fixture_root="$FIXTURE/$mode-$phase"
    mkdir -p "$fixture_root"
    if [[ "$phase" == upgrade ]]; then
      mkdir -p "$fixture_root/.agents"
      cp -R "$FIXTURE/meta/agent/." "$fixture_root/.agents/"
      printf 'old navigation\n' >"$fixture_root/.agents/skills/demo/references/README.md"
    fi
    if [[ "$mode" == fallback ]]; then export PATH="$FIXTURE/bin"; else export PATH="$test_base_path"; fi
    run_agent_install "$fixture_root" --meta "$FIXTURE/meta" --scope=a --agents=codex --dry-run >"$fixture_root/preview" 2>&1
    if [[ "$phase" == fresh ]]; then
      assert_dir_not_exists "$fixture_root/.agents"
    else
      assert_contains 'old navigation' "$fixture_root/.agents/skills/demo/references/README.md"
      for item in "${excluded[@]}"; do assert_file_exists "$fixture_root/.agents/$item"; done
    fi
    run_agent_install "$fixture_root" --meta "$FIXTURE/meta" --scope=a --agents=codex >"$fixture_root/out" 2>&1
    for item in "${retained[@]}"; do
      assert_file_exists "$fixture_root/.agents/$item"
      assert_contains 'reference navigation' "$fixture_root/.agents/$item"
    done
    for item in "${excluded[@]}"; do assert_file_not_exists "$fixture_root/.agents/$item"; done
    assert_file_exists "$fixture_root/.codex/skills/demo/references/README.md"
    assert_file_exists "$fixture_root/.codex/references/README.md"
  done
done
export PATH="$test_base_path"
for item in "${retained[@]}" "${excluded[@]}"; do assert_file_exists "$FIXTURE/meta/agent/$item"; done
pass '仅 references/README.md 豁免；两种复制路径与升级一致，研发目录仍排除，预览只读'
