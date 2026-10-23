#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_ROOT="$(cd "$TEST_ROOT/../../.." && pwd)"
source "$META_ROOT/agent/scripts/lib/bash.sh"
source "$META_ROOT/agent/scripts/test-core.sh"
export PYTHONDONTWRITEBYTECODE=1

# 单注册表：短名 | 相对仓库根的 runner | 最小运行模式（quick 也加入 full）。
SUITE_REGISTRY=(
  'bash-guard|agent/scripts/tests/bash-guard/run.sh|quick'
  'shared-config|agent/scripts/tests/shared-config/run.sh|quick'
  'shared-io|agent/scripts/tests/shared-io/run.sh|quick'
  'shared-runtime|agent/scripts/tests/shared-runtime/run.sh|quick'
  'test-core|agent/scripts/tests/test-core/run.sh|quick'
  'refresh-codex|agent/scripts/tests/refresh-codex/run.sh|quick'
  'docs-publish|agent/skills/docs-publish/tests/run.sh|quick'
  'forbidden-file-refs|agent/scripts/tests/forbidden-file-refs/run.sh|quick'
  'link-reachable|agent/scripts/tests/link-reachable/run.sh|quick'
  'docs-link|agent/skills/docs-link/tests/run.sh|quick'
  'okf|agent/scripts/tests/okf/run.sh|quick'
  'docs-okf|agent/skills/docs-okf/tests/run.sh|quick'
  'agent-install|agent/skills/agent-install/tests/run.sh|quick'
  'bootstrap|agent/scripts/tests/bootstrap/run.sh|quick'
  'docs-install|agent/skills/docs-install/tests/run.sh|full'
  'docs-upgrade|agent/skills/docs-upgrade/tests/run.sh|full'
  'docs-indexing|agent/skills/docs-indexing/tests/run.sh|full'
  'sdx-analysis|agent/skills/sdx-analysis/tests/run.sh|full'
  'sdx-feature|agent/skills/sdx-feature/tests/run.sh|full'
  'sdx-prd|agent/skills/sdx-prd/tests/run.sh|full'
  'sdx-architect|agent/skills/sdx-architect/tests/run.sh|full'
  'sdx-design|agent/skills/sdx-design/tests/run.sh|full'
  'sdx-test|agent/skills/sdx-test/tests/run.sh|full'
  'sdx-solution|agent/skills/sdx-solution/tests/run.sh|full'
  'sdx-domains|agent/skills/sdx-domains/tests/run.sh|full'
  'docs-archive|agent/skills/docs-archive/tests/run.sh|full'
  'docs-build|agent/skills/docs-build/tests/run.sh|full'
  'docs-distill|agent/skills/docs-distill/tests/run.sh|full'
  'docs-merge|agent/skills/docs-merge/tests/run.sh|full'
  'docs-revise|agent/skills/docs-revise/tests/run.sh|full'
  'docs-simplify|agent/skills/docs-simplify/tests/run.sh|full'
  'docs-tag|agent/skills/docs-tag/tests/run.sh|full'
  'docs-okf-browser|agent/skills/docs-okf/tests/run-browser.sh|explicit'
)

QUICK_SUITES=()
FULL_SUITES=()
for suite_entry in "${SUITE_REGISTRY[@]}"; do
  IFS='|' read -r suite_name suite_path suite_mode <<<"$suite_entry"
  [[ "$suite_mode" == explicit ]] || FULL_SUITES+=("$suite_name")
  [[ "$suite_mode" != quick ]] || QUICK_SUITES+=("$suite_name")
done
unset suite_entry suite_name suite_path suite_mode

# 短名解析使用同一注册表；含路径者仍按仓库根解析。
suite_runner() {
  local entry name runner mode
  for entry in "${SUITE_REGISTRY[@]}"; do
    IFS='|' read -r name runner mode <<<"$entry"
    if [[ "$name" == "$1" ]]; then
      printf '%s\n' "$runner"
      return 0
    fi
  done
  return 1
}

MODE='quick'
SUITE=''

usage() {
  cat <<EOF
用法: bash agent/scripts/tests/run.sh [--quick|--full] [--suite NAME]

  --quick（默认）  ${QUICK_SUITES[*]}
  --full           ${FULL_SUITES[*]}
  --suite NAME     仅运行指定套件（短名或 agent/.../run.sh）
  显式可选套件     docs-okf-browser（需既有 Node/Playwright/浏览器及匹配 SRI 的资产）
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --quick) MODE='quick'; shift ;;
    --full)  MODE='full'; shift ;;
    --suite)
      [[ $# -ge 2 ]] || test_fail "缺少 --suite 值"
      SUITE="$2"; shift 2 ;;
    --suite=*) SUITE="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数: %s\n' "$1" >&2; usage; exit 1 ;;
    esac
  done
}

run_suite() {
  local name="${1:?suite name is required}"
  local runner runner_rel
  if runner_rel="$(suite_runner "$name")"; then
    runner="$META_ROOT/$runner_rel"
  elif [[ "$name" == */* ]]; then
    runner="$META_ROOT/$name"
  else
    runner="$TEST_ROOT/$name/run.sh"
  fi
  [[ -f "$runner" ]] || test_fail "未找到套件 runner: $runner"
  printf '\n'
  printf '########## suite: %s ##########\n' "$name"
  (cd "$META_ROOT" && "$(test_bash5_command)" "$runner")
}

main() {
  parse_args "$@"

  if [[ -n "$SUITE" ]]; then
    run_suite "$SUITE"
    exit $?
  fi

  local -a suites=()
  local failed=0
  local s

  if [[ "$MODE" == 'full' ]]; then
    suites=("${FULL_SUITES[@]}")
  else
    suites=("${QUICK_SUITES[@]}")
  fi

  for s in "${suites[@]}"; do
    run_suite "$s" || failed=$((failed + 1))
  done

  printf '\n'
  printf '== agent/scripts/tests 聚合结果 ==\n'
  if [[ "$failed" -gt 0 ]]; then
    printf '失败套件数: %d\n' "$failed"
    exit 1
  fi
  printf '[OK] 全部套件通过（mode=%s）\n' "$MODE"
}

main "$@"
