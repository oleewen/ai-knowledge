#!/usr/bin/env bash
set -euo pipefail

# OKF refresh 编排：frontmatter → index → viz → 校验。
# 实体分表 INDEX-GUIDE.md 第四章由 /docs-build 写入，本脚本不写。
# 用法: bash {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts/okf-indexing.sh [--bundle PATH] [--dry-run]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVE="${SCRIPT_DIR}/resolve-okf-paths.sh"
BUNDLE="${BUNDLE:-}"
DRY_RUN=0

usage() {
  cat <<EOF
用法: bash {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts/okf-indexing.sh [--bundle PATH] [--dry-run]

按序执行 OKF refresh / validate（可重复运行）：
  1. inject_frontmatter
  2. generate_index（--recursive）
  3. visualize
  4. validate-okf
  5. validate-viz-index

视角导航块 {DOC_DIR}/INDEX-GUIDE.md 第四章 → /docs-build（generate_knowledge_index.py）。

须有效 .docsconfig（含 KNOWLEDGE_TYPE、AGENT_DIR）。bundle 与默认 viz 输出取自 DOC_DIR；页面名称取自 KNOWLEDGE_TYPE。
脚本路径取自 {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts（不依赖 \$repo_abs/agent/）。

环境变量:
  BUNDLE   覆盖 .docsconfig 推导的 bundle（DOC_DIR）
EOF
}

# shellcheck disable=SC1091
source "$RESOLVE"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bundle)
      okf_require_bundle_value "${2:-}"
      BUNDLE="$2"
      shift 2
      ;;
    --bundle=*)
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
run_cmd "inject_frontmatter" python3 "${inject_args[@]}"

index_args=(
  "$OKF_DIR/generate_index.py"
  --bundle "$BUNDLE"
  --recursive
)
if [[ "$DRY_RUN" -eq 1 ]]; then
  index_args+=(--dry-run)
fi
run_cmd "generate_index" python3 "${index_args[@]}"

run_cmd "visualize" python3 \
  "$OKF_DIR/visualize.py" \
  --bundle "$BUNDLE" \
  --out "$OKF_VIZ_OUT" \
  --name "$OKF_VIZ_NAME"

run_cmd "validate-okf" "${BASH:-$(command -v bash)}" "$OKF_DIR/okf-validate.sh" --bundle "$BUNDLE"
run_cmd "validate-viz-index" python3 \
  "$OKF_DIR/validate_viz_index.py" \
  --bundle "$BUNDLE" \
  --viz "$OKF_VIZ_OUT"

echo ""
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "=== okf-refresh 预览结束（未执行、未校验） ==="
else
  echo "=== okf-refresh 完成 ==="
fi
