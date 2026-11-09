#!/usr/bin/env bash
set -euo pipefail

# OKF refresh 编排：frontmatter → index → viz → 校验。
# 实体分表 INDEX-GUIDE.md 第四章由 /docs-build 写入，本脚本不写。
# 用法: bash {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts/okf-indexing.sh [--bundle PATH] [--layer LAYER] [--consumer-root PATH ...] [--dry-run]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVE="${SCRIPT_DIR}/resolve-okf-paths.sh"
BUNDLE="${BUNDLE:-}"
DRY_RUN=0
LAYER_ARGS=()
CONSUMER_ARGS=()
BUNDLE_EXPLICIT=0

usage() {
  cat <<EOF
用法: bash {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts/okf-indexing.sh [--bundle PATH] [--layer LAYER] [--consumer-root PATH ...] [--dry-run]

按序执行 OKF refresh / validate（可重复运行）：
  1. inject_frontmatter
  2. generate_index（--recursive）
  3. visualize
  4. validate-okf
  5. validate-viz-index

视角导航块 {DOC_DIR}/INDEX-GUIDE.md 第四章 → /docs-build（generate_knowledge_index.py）。

须有效 .docsconfig（含 KNOWLEDGE_TYPE、AGENT_DIR）。bundle 与默认 viz 输出取自 DOC_DIR；页面名称取自 KNOWLEDGE_TYPE。
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
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "未知参数: $1（支持 --bundle PATH、--dry-run）" >&2
      exit 1
      ;;
  esac
done

resolve_okf_target "$BUNDLE"
if [[ "$KNOWLEDGE_TYPE" == meta && ( "$BUNDLE_EXPLICIT" == 0 || ${#LAYER_ARGS[@]} == 0 ) ]]; then
  echo '元库必须显式指定 --layer 与 --bundle；尚未写入' >&2
  exit 1
fi
if (( ${#LAYER_ARGS[@]} )); then
  case "${LAYER_ARGS[1]}" in application|system|solution|company) ;; *) echo '非法 --layer' >&2; exit 1 ;; esac
  if [[ "$KNOWLEDGE_TYPE" != meta && "$KNOWLEDGE_TYPE" != "${LAYER_ARGS[1]}" ]]; then
    echo '--layer 与配置逻辑层冲突；尚未写入' >&2; exit 1
  fi
fi

run_cmd() {
  local desc="$1"
  shift
  echo ""
  echo "=== ${desc} ==="
  printf ">>> "
  printf '%q ' "$@"
  printf '\n'
  if [[ "$DRY_RUN" -eq 0 ]]; then
    "$@"
  fi
}

export DOCS_OKF_REPO_ABS="$repo_abs"
export KNOWLEDGE_VALIDATION_BASH="$BASH"
export PYTHONDONTWRITEBYTECODE=1
cd "$repo_abs"

echo "=== okf-refresh ==="
echo "repo_abs:      ${repo_abs}"
echo "DOC_DIR:        ${DOC_DIR}"
echo "AGENT_DIR:      ${AGENT_DIR}"
echo "OKF_SCRIPTS:    ${OKF_DIR}"
echo "KNOWLEDGE_TYPE: ${KNOWLEDGE_TYPE}"
echo "BUNDLE:         ${BUNDLE}"
echo "OKF_VIZ_OUT:    ${OKF_VIZ_OUT}"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "MODE:           dry-run（仅打印命令）"
fi

inject_args=(
  "$OKF_DIR/inject_frontmatter.py"
  --bundle "$BUNDLE"
)
run_cmd "output-preflight" python3 "$OKF_DIR/artifact_checks.py" --bundle "$BUNDLE" --viz "$OKF_VIZ_OUT"
if [[ "$DRY_RUN" -eq 1 ]]; then
  inject_args+=(--dry-run)
fi
run_cmd "identity-preflight" python3 "$OKF_DIR/generate_index.py" --bundle "$BUNDLE" --recursive --dry-run "${LAYER_ARGS[@]}" "${CONSUMER_ARGS[@]}"
run_cmd "inject_frontmatter" python3 "${inject_args[@]}"

index_args=(
  "$OKF_DIR/generate_index.py"
  --bundle "$BUNDLE"
  --recursive
  "${LAYER_ARGS[@]}"
  "${CONSUMER_ARGS[@]}"
)
if [[ "$DRY_RUN" -eq 1 ]]; then
  index_args+=(--dry-run)
fi
run_cmd "generate_index" python3 "${index_args[@]}"

run_cmd "visualize" python3 \
  "$OKF_DIR/visualize.py" \
  --bundle "$BUNDLE" \
  --out "$OKF_VIZ_OUT" \
  --name "$OKF_VIZ_NAME" "${LAYER_ARGS[@]}" "${CONSUMER_ARGS[@]}"

run_cmd "validate-okf" "${BASH:-$(command -v bash)}" "$OKF_DIR/okf-validate.sh" --bundle "$BUNDLE" "${LAYER_ARGS[@]}" "${CONSUMER_ARGS[@]}"
run_cmd "validate-viz-index" python3 \
  "$OKF_DIR/validate_viz_index.py" \
  --bundle "$BUNDLE" \
  --viz "$OKF_VIZ_OUT" "${LAYER_ARGS[@]}" "${CONSUMER_ARGS[@]}"

echo ""
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "=== okf-refresh 预览结束（未执行、未校验） ==="
else
  echo "=== okf-refresh 完成 ==="
fi
