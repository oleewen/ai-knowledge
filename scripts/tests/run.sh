#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_ROOT/../.." && pwd)"

QUICK_SUITES=(forbidden-file-refs docs-link docs-change okf)
FULL_SUITES=(forbidden-file-refs docs-link docs-change okf docs-install docs-push)

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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quick) MODE='quick'; shift ;;
    --full)  MODE='full'; shift ;;
    --suite)
      [[ $# -ge 2 ]] || { echo "缺少 --suite 值" >&2; exit 1; }
      SUITE="$2"; shift 2 ;;
    --suite=*) SUITE="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知参数: $1" >&2; usage; exit 1 ;;
  esac
done

run_suite() {
  local name="$1"
  local runner="$TEST_ROOT/$name/run.sh"
  if [[ ! -f "$runner" ]]; then
    echo "[FAIL] 未找到套件 runner: $runner" >&2
    return 1
  fi
  echo ""
  echo "########## suite: $name ##########"
  (cd "$REPO_ROOT" && bash "$runner")
}

if [[ -n "$SUITE" ]]; then
  run_suite "$SUITE"
  exit $?
fi

if [[ "$MODE" == 'full' ]]; then
  SUITES=("${FULL_SUITES[@]}")
else
  SUITES=("${QUICK_SUITES[@]}")
fi

failed=0
for s in "${SUITES[@]}"; do
  run_suite "$s" || failed=$((failed + 1))
done

echo ""
echo "== scripts/tests 聚合结果 =="
if [[ "$failed" -gt 0 ]]; then
  echo "失败套件数: $failed"
  exit 1
fi
echo "[OK] 全部套件通过（mode=${MODE}）"
