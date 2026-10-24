#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
source "$ROOT/agent/scripts/test-core.sh"

BASH5="$(test_bash5_command)" || test_fail '需要 Bash 5+ 执行 CLI fixture'
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

make_fixture() {
  local fixture="$TMP/fixture"
  mkdir -p "$fixture/agent/skills/docs-publish/scripts" "$fixture/agent/scripts/lib"
  cp "$ROOT/agent/skills/docs-publish/scripts/docs-publish.sh" "$fixture/agent/skills/docs-publish/scripts/"
  cp "$ROOT/agent/scripts/lib/version.sh" "$fixture/agent/scripts/lib/"
  for layer in application system solution company; do
    mkdir -p "$fixture/$layer"
    printf 'version: %s.3\n' "$(date +%Y.%m%d)" >"$fixture/$layer/DESIGN.md"
  done
  printf 'initial\n' >"$fixture/TODO-LIST.md"
  git -C "$fixture" init -q -b main
  git -C "$fixture" config user.email test@example.com
  git -C "$fixture" config user.name 'Docs Publish Test'
  git -C "$fixture" add .
  git -C "$fixture" commit -qm initial
  git -C "$TMP" init -q --bare remote.git
  git -C "$fixture" remote add origin "$TMP/remote.git"
  git -C "$fixture" push -q -u origin main
  git -C "$fixture" switch -q -c feature-work
  printf '%s\n' "$fixture"
}

fixture="$(make_fixture)"
script="$fixture/agent/skills/docs-publish/scripts/docs-publish.sh"

output="$(cd "$fixture/application" && "$BASH5" "$script" 2>&1)" \
  || test_fail "默认模式应仅预览并成功: $output"
help_output="$(cd "$fixture" && "$BASH5" "$script" --help 2>&1)" \
  || test_fail "--help 应成功: $help_output"
[[ "$help_output" == *'--publish'* ]] || test_fail "帮助文本缺少 --publish: $help_output"

if output="$(cd "$fixture/application" && "$BASH5" "$script" --dry-run 2>&1)"; then
  :
else
  test_fail "从子目录执行 --dry-run 应成功: $output"
fi
assert_contains 'docs-publish:' <(printf '%s\n' "$output")
assert_not_contains 'Published ' <(printf '%s\n' "$output")

rm "$fixture/TODO-LIST.md"
output="$(cd "$fixture" && "$BASH5" "$script" --dry-run 2>&1)" \
  || test_fail "已跟踪 TODO 删除也应进入预览: $output"
assert_contains 'TODO-LIST.md' <(printf '%s\n' "$output")
git -C "$fixture" restore TODO-LIST.md

if output="$(cd "$fixture" && "$BASH5" "$script" --dry-run --publish 2>&1)"; then
  test_fail '不能同时指定 --dry-run 与 --publish'
fi
assert_contains '互斥' <(printf '%s\n' "$output")

printf 'unrelated\n' >"$fixture/unrelated.txt"
if output="$(cd "$fixture" && "$BASH5" "$script" --dry-run 2>&1)"; then
  test_fail '存在未允许改动时应硬停'
fi
assert_contains 'unrelated working-tree change' <(printf '%s\n' "$output")

git -C "$fixture" switch -q main
if output="$(cd "$fixture" && "$BASH5" "$script" --dry-run 2>&1)"; then
  test_fail '主分支上应拒绝运行发布预览'
fi
assert_contains 'cannot publish from main' <(printf '%s\n' "$output")
git -C "$fixture" switch -q feature-work

rm -f "$fixture/unrelated.txt"
printf 'version: %s.4\n' "$(date +%Y.%m%d)" >"$fixture/system/DESIGN.md"
if output="$(cd "$fixture" && "$BASH5" "$script" --dry-run 2>&1)"; then
  test_fail '四层版本不一致时应硬停'
fi
assert_contains 'DESIGN versions are missing, invalid, or inconsistent' <(printf '%s\n' "$output")

pass '默认预览、子目录执行、模式互斥、脏改动、分支与版本门禁'
