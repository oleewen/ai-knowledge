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
printf 'base\n' > "$fixture/README.md"
git -C "$fixture" add .
git -C "$fixture" commit -qm initial
git -C "$TMP" init -q --bare remote.git
git -C "$fixture" remote add origin "$TMP/remote.git"
git -C "$fixture" push -q -u origin main
git -C "$fixture" switch -q -c feature-work
printf 'follow-up\n' >>"$fixture/TODO-LIST.md"
printf 'follow-up\n' >>"$fixture/application/TODO-LIST.md"


script="$fixture/agent/skills/docs-publish/scripts/docs-publish.sh"
run_publish() { (cd "$fixture" && "$BASH5" "$script" "$@"); }
printf 'staged only\n' > "$fixture/README.md"
git -C "$fixture" add README.md
git -C "$fixture" show HEAD:README.md > "$fixture/README.md"
if run_publish --dry-run > "$TMP/out" 2>&1; then fail '漏检暂存区独立改动'; fi
git -C "$fixture" restore --staged README.md
plan="$(run_publish --dry-run | sed -n 's/^plan-id: //p')"
[[ "$plan" =~ ^[a-f0-9]{64}$ ]] || fail '预览须输出计划标识'
head_before="$(git -C "$fixture" rev-parse HEAD)"
printf 'changed after preview\n' >> "$fixture/TODO-LIST.md"
if run_publish --publish --expect-plan "$plan" > "$TMP/out" 2>&1; then fail '旧计划不得发布新内容'; fi
assert_contains 'plan' "$TMP/out"
[[ "$(git -C "$fixture" rev-parse HEAD)" == "$head_before" ]] || fail '计划失配前不得rebase/commit'
assert_contains "version: $(date +%Y.%m%d).0" "$fixture/application/DESIGN.md"
pass '暂存区独立范围检查与预览计划内容绑定'
