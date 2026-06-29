#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_ROOT/../.." && pwd)"
source "$REPO_ROOT/agent/scripts/test-core.sh"

QUICK_SUITES=("agent/scripts/tests/forbidden-file-refs/run.sh" docs-link docs-change okf docs-okf agent-install docs-meta-naming)
FULL_SUITES=("agent/scripts/tests/forbidden-file-refs/run.sh" docs-link docs-change okf docs-okf agent-install docs-meta-naming docs-install docs-push)

MODE='quick'
SUITE=''

usage() {
  cat <<EOF
用法: bash scripts/tests/run.sh [--quick|--full] [--suite NAME]

  --quick（默认）  ${QUICK_SUITES[*]}
  --full           ${FULL_SUITES[*]}
  --suite NAME     仅运行指定套件
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
  local runner
  if [[ "$name" == */* ]]; then
    runner="$REPO_ROOT/$name"
  else
    runner="$TEST_ROOT/$name/run.sh"
  fi
  [[ -f "$runner" ]] || test_fail "未找到套件 runner: $runner"
  printf '\n'
  printf '########## suite: %s ##########\n' "$name"
  (cd "$REPO_ROOT" && bash "$runner")
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
  printf '== scripts/tests 聚合结果 ==\n'
  if [[ "$failed" -gt 0 ]]; then
    printf '失败套件数: %d\n' "$failed"
    exit 1
  fi
  printf '[OK] 全部套件通过（mode=%s）\n' "$MODE"
}

main "$@"
