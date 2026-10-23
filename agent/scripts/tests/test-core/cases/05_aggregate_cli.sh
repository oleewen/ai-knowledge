#!/usr/bin/env bash
set -euo pipefail
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS/test-core.sh"

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/agent/scripts/lib" "$fixture/agent/scripts/tests/lib"
cp "$SCRIPTS/test-core.sh" "$fixture/agent/scripts/"
cp "$SCRIPTS/lib/"{path,bash}.sh "$fixture/agent/scripts/lib/"
cp "$SCRIPTS/tests/lib/"{assertions,runner}.sh "$fixture/agent/scripts/tests/lib/"
cp "$SCRIPTS/tests/run.sh" "$fixture/agent/scripts/tests/run.sh"

# 替代套件仅记录编排顺序，避免测试聚合器时执行实际安装或刷新工作。
skill_suites=(docs-upgrade docs-indexing sdx-analysis sdx-feature sdx-prd sdx-architect sdx-design sdx-test sdx-solution sdx-domains docs-archive docs-build docs-distill docs-merge docs-revise docs-simplify docs-tag)
for name in bash-guard shared-config shared-io shared-runtime test-core codex-daemon-watch refresh-codex docs-publish forbidden-file-refs link-reachable docs-link okf docs-okf agent-install bootstrap docs-install "${skill_suites[@]}" docs-okf-browser; do
  case "$name" in
    docs-okf-browser)
      runner="$fixture/agent/skills/docs-okf/tests/run-browser.sh" ;;
    docs-*|sdx-*|agent-install)
      runner="$fixture/agent/skills/$name/tests/run.sh" ;;
    *) runner="$fixture/agent/scripts/tests/$name/run.sh" ;;
  esac
  mkdir -p "$(dirname "$runner")"
  printf 'printf "%%s\\n" %q >>"$SUITE_TRACE"\n[[ "${FAIL_SUITE:-}" != %q ]]\n' "$name" "$name" >"$runner"
done

aggregate="$fixture/agent/scripts/tests/run.sh"
export SUITE_TRACE="$fixture/trace"
expected_quick=$'bash-guard\nshared-config\nshared-io\nshared-runtime\ntest-core\ncodex-daemon-watch\nrefresh-codex\ndocs-publish\nforbidden-file-refs\nlink-reachable\ndocs-link\nokf\ndocs-okf\nagent-install\nbootstrap'
"$BASH" "$aggregate" --help >"$fixture/help"
[[ ! -e "$SUITE_TRACE" ]] || fail '帮助调用执行了套件'
assert_contains 'shared-config shared-io shared-runtime test-core' "$fixture/help"
"$BASH" "$aggregate" >"$fixture/output"
[[ "$(cat "$SUITE_TRACE")" == "$expected_quick" ]] || fail '默认 quick 套件集合或顺序改变'
: >"$SUITE_TRACE"
"$BASH" "$aggregate" --full >"$fixture/output"
expected_full="$expected_quick"$'\ndocs-install\n'"$(printf '%s\n' "${skill_suites[@]}")"
[[ "$(cat "$SUITE_TRACE")" == "$expected_full" ]] || fail 'full 套件集合或顺序改变'

for selection in test-core agent/scripts/tests/test-core/run.sh docs-okf-browser; do
  : >"$SUITE_TRACE"
  "$BASH" "$aggregate" --suite "$selection" >"$fixture/output"
  expected_selection=test-core
  [[ "$selection" != docs-okf-browser ]] || expected_selection=docs-okf-browser
  [[ "$(cat "$SUITE_TRACE")" == "$expected_selection" ]] || fail '单套件短名或路径选择失效'
done
: >"$SUITE_TRACE"
if FAIL_SUITE=test-core "$BASH" "$aggregate" --quick >"$fixture/output"; then
  fail '聚合器吞掉失败套件退出码'
fi
[[ "$(cat "$SUITE_TRACE")" == "$expected_quick" ]] || fail '聚合器遇到失败后未继续'
assert_contains '失败套件数: 1' "$fixture/output"
if "$BASH" "$aggregate" --suite absent >"$fixture/output" 2>&1; then
  fail '聚合器接受了缺失套件'
fi
pass '聚合 quick/full 顺序、帮助、单套件与失败传播保持'
