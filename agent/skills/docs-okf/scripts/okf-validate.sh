#!/usr/bin/env bash
set -euo pipefail

# OKF bundle 校验入口。须有效 .docsconfig（含 KNOWLEDGE_TYPE、AGENT_DIR）。
# 用法: bash {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts/okf-validate.sh [--bundle NAME] [--layer LAYER] [--consumer-root PATH ...]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVE="${SCRIPT_DIR}/resolve-okf-paths.sh"

BUNDLE="${BUNDLE:-}"
LAYER_ARGS=()
CONSUMER_ARGS=()
BUNDLE_EXPLICIT=0

usage() {
  cat <<EOF
用法: bash {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts/okf-validate.sh [--bundle NAME] [--layer LAYER] [--consumer-root PATH ...]

调用统一核心校验实体、关系与必需引用；保留根索引检查。元库须显式 --bundle 与 --layer。
bundle 与默认 viz 输出取自 .docsconfig 的 DOC_DIR；KNOWLEDGE_TYPE、AGENT_DIR 必填。
脚本路径取自 {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts（不依赖 \$repo_abs/agent/）。

--consumer-root 可重复：追加消费声明扫描根，并递归已登记 child；parent/dependency 仅供目标定位。输出报告实际覆盖范围。

环境变量:
  BUNDLE   覆盖 .docsconfig 推导的 bundle（DOC_DIR）
EOF
}

# shellcheck disable=SC1091
source "$RESOLVE"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --consumer-root)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || { echo '缺少 --consumer-root' >&2; exit 1; }
      CONSUMER_ARGS+=(--consumer-root "$2"); shift 2 ;;
    --consumer-root=*)
      [[ -n "${1#*=}" ]] || { echo '缺少 --consumer-root' >&2; exit 1; }
      CONSUMER_ARGS+=(--consumer-root "${1#*=}"); shift ;;
    --layer)
      [[ $# -ge 2 ]] || { echo "缺少 --layer" >&2; exit 1; }
      LAYER_ARGS=(--layer "$2"); shift 2 ;;
    --layer=*) LAYER_ARGS=(--layer "${1#*=}"); shift ;;
    --bundle)
      BUNDLE_EXPLICIT=1
      okf_require_bundle_value "${2:-}"
      BUNDLE="$2"
      shift 2
      ;;
    --bundle=*)
      BUNDLE_EXPLICIT=1
      BUNDLE="${1#*=}"
      okf_require_bundle_value "$BUNDLE"
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "未知参数: $1（支持 --bundle NAME）" >&2
      exit 1
      ;;
  esac
done

resolve_okf_target "$BUNDLE"
if [[ "$KNOWLEDGE_TYPE" == meta && ( "$BUNDLE_EXPLICIT" == 0 || ${#LAYER_ARGS[@]} == 0 ) ]]; then
  echo '元库必须显式指定 --layer 与 --bundle' >&2
  exit 1
fi

cd "$repo_abs" || exit 1
export DOCS_OKF_REPO_ABS="$repo_abs"
export PYTHONDONTWRITEBYTECODE=1
export KNOWLEDGE_VALIDATION_BASH="$BASH"

echo "=== validate-okf ==="
echo "repo_abs:      ${repo_abs}"
echo "DOC_DIR:        ${DOC_DIR}"
echo "AGENT_DIR:      ${AGENT_DIR}"
echo "OKF_SCRIPTS:    ${OKF_DIR}"
echo "KNOWLEDGE_TYPE: ${KNOWLEDGE_TYPE}"
echo "BUNDLE:         ${BUNDLE}"
echo "OKF_VIZ_OUT:    ${OKF_VIZ_OUT}"
echo ""

python3 "$OKF_DIR/validate_bundle.py" --bundle "$BUNDLE" --repo "$repo_abs" "${LAYER_ARGS[@]}" "${CONSUMER_ARGS[@]}"
