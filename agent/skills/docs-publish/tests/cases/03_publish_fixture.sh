#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
source "$ROOT/agent/scripts/test-core.sh"

BASH5="$(test_bash5_command)" || test_fail '需要 Bash 5+ 执行 publish fixture'
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fixture="$TMP/fixture"
mkdir -p "$fixture/agent/skills/docs-publish/scripts" "$fixture/agent/scripts/lib"
cp "$ROOT/agent/skills/docs-publish/scripts/docs-publish.sh" "$fixture/agent/skills/docs-publish/scripts/"
cp "$ROOT/agent/scripts/lib/version.sh" "$fixture/agent/scripts/lib/"
for layer in application system solution company; do
  mkdir -p "$fixture/$layer"
  printf 'version: %s.0\n' "$(date +%Y.%m%d)" >"$fixture/$layer/DESIGN.md"
done
printf 'initial\n' >"$fixture/TODO-LIST.md"
printf 'initial\n' >"$fixture/application/TODO-LIST.md"
git -C "$fixture" init -q -b main
git -C "$fixture" config user.email test@example.com
git -C "$fixture" config user.name 'Docs Publish Test'
git -C "$fixture" add .
git -C "$fixture" commit -qm initial
git -C "$TMP" init -q --bare remote.git
git -C "$fixture" remote add origin "$TMP/remote.git"
git -C "$fixture" push -q -u origin main
git -C "$fixture" switch -q -c feature-work
printf 'follow-up\n' >>"$fixture/TODO-LIST.md"
printf 'follow-up\n' >>"$fixture/application/TODO-LIST.md"

output="$(cd "$fixture" && "$BASH5" agent/skills/docs-publish/scripts/docs-publish.sh --publish 2>&1)" \
  || test_fail "--publish fixture 失败: $output"
assert_contains 'Published ' <(printf '%s\n' "$output")

expected="$(date +%Y.%m%d).1"
next="$(date +%Y.%m%d).2"
for layer in application system solution company; do
  assert_contains "version: $expected" "$fixture/$layer/DESIGN.md"
done
subject="$(git -C "$fixture" log -1 --format=%s)"
[[ "$subject" == "docs-publish: version $expected" ]] \
  || test_fail "commit subject 错误: $subject"
body="$(git -C "$fixture" log -1 --format=%B)"
assert_contains 'Previous version:' <(printf '%s\n' "$body")
assert_contains 'TODO-LIST.md' <(printf '%s\n' "$body")
assert_contains 'application/TODO-LIST.md' <(printf '%s\n' "$body")
git -C "$fixture" diff --quiet || test_fail '发布完成后工作树应干净'
[[ "$(git -C "$fixture" branch --show-current)" == "feature-$next" ]] \
  || test_fail '发布后应切换到下一 feature 分支'
git --git-dir="$TMP/remote.git" show-ref --verify --quiet "refs/heads/main" \
  || test_fail '远端 main 不存在'
git --git-dir="$TMP/remote.git" show-ref --verify --quiet "refs/heads/feature-work" \
  || test_fail '远端 feature 分支不存在'

pass 'publish 提交流程、动态 commit body、远端快进与下一分支'
