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
run_publish() { (cd "$fixture" && "$BASH5" "$script" "$@"); }
plan() { run_publish --dry-run | sed -n 's/^plan-id: //p'; }
reject_plan() {
  local expected="$1" head
  head="$(git -C "$fixture" rev-parse HEAD)"
  if run_publish --publish --expect-plan "$expected" > "$TMP/out" 2>&1; then fail '过期计划不应发布'; fi
  assert_contains 'plan' "$TMP/out"
  [[ "$(git -C "$fixture" rev-parse HEAD)" == "$head" ]] || fail '拒绝前发生rebase/commit'
}
original_plan="$(plan)"
reject_plan "$(printf '%064d' 0)"
cp "$fixture/application/DESIGN.md" "$TMP/design"
printf '# Changed content\n' >> "$fixture/application/DESIGN.md"
reject_plan "$original_plan"
cp "$TMP/design" "$fixture/application/DESIGN.md"
# 同样总差异，改为暂存态也须使标识变化。
git -C "$fixture" add TODO-LIST.md
reject_plan "$original_plan"
git -C "$fixture" restore --staged TODO-LIST.md
# 只替换日期命令，验证跨日后目标版本变化。
mkdir "$TMP/bin"
real_date="$(command -v date)"
next_day="$(python3 -c 'import datetime; print((datetime.date.today()+datetime.timedelta(days=1)).strftime("%Y.%m%d"))')"
cat > "$TMP/bin/date" <<CLOCK
#!/usr/bin/env bash
if [[ "\$*" == '+%Y.%m%d' ]]; then printf '%s\n' '$next_day'; else '$real_date' "\$@"; fi
CLOCK
chmod +x "$TMP/bin/date"
old_path="$PATH"
export PATH="$TMP/bin:$PATH"
reject_plan "$original_plan"
export PATH="$old_path"
# 真正的本地远端变化：先测 publish fetch 发现，再测外部 fetch 已更新tracking。
git clone -q -b main "$TMP/remote.git" "$TMP/upstream"
git -C "$TMP/upstream" config user.name Fixture
git -C "$TMP/upstream" config user.email fixture@example.invalid
for mode in internal external; do
  original_plan="$(plan)"
  printf '%s\n' "$mode" >> "$TMP/upstream/TODO-LIST.md"
  git -C "$TMP/upstream" add TODO-LIST.md
  git -C "$TMP/upstream" commit -qm "remote $mode"
  git -C "$TMP/upstream" push -q origin main
  [[ "$mode" != external ]] || git -C "$fixture" fetch -q origin main
  reject_plan "$original_plan"
done
pass '错误标识、正文变化、暂存态、跨日及内外fetch变化均拒绝'
