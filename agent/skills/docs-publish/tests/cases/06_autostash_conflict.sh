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


script="$fixture/agent/skills/docs-publish/scripts/docs-publish.sh"
git clone -q -b main "$TMP/remote.git" "$TMP/upstream"
git -C "$TMP/upstream" config user.name Fixture
git -C "$TMP/upstream" config user.email fixture@example.invalid
printf 'upstream\n' > "$TMP/upstream/TODO-LIST.md"
git -C "$TMP/upstream" add TODO-LIST.md
git -C "$TMP/upstream" commit -qm upstream
git -C "$TMP/upstream" push -q origin main
git -C "$fixture" fetch -q origin main
printf 'local\n' > "$fixture/TODO-LIST.md"
plan="$(cd "$fixture" && "$BASH5" "$script" --dry-run | sed -n 's/^plan-id: //p')"
if (cd "$fixture" && "$BASH5" "$script" --publish --expect-plan "$plan") > "$TMP/out" 2>&1; then fail 'autostash冲突不得继续发布'; fi
[[ -n "$(git -C "$fixture" ls-files --unmerged)" ]] || fail '须保留未合并现场'
assert_not_contains 'Published ' "$TMP/out"
[[ "$(git --git-dir="$TMP/remote.git" log -1 --format=%s main)" == upstream ]] || fail '不应推送发布提交'
assert_contains "version: $(date +%Y.%m%d).0" "$fixture/application/DESIGN.md"
pass 'autostash恢复冲突返回0时仍阻止版本写入和发布，保留现场'
