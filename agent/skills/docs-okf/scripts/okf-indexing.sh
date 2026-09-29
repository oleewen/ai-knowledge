#!/usr/bin/env bash
set -euo pipefail

# OKF refresh 编排：frontmatter → index → viz → 校验。
# 实体分表 INDEX-GUIDE.md 第四章由 /docs-build 写入，本脚本不写。
# 用法: bash {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts/okf-indexing.sh [--dry-run]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVE="${SCRIPT_DIR}/resolve-okf-paths.sh"
BUNDLE="${BUNDLE:-}"
BUNDLE_OVERRIDE=0
[[ -n "$BUNDLE" ]] && BUNDLE_OVERRIDE=1
DRY_RUN=0

usage() {
  cat <<EOF
用法: bash {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts/okf-indexing.sh [--dry-run]

按序执行 OKF refresh / validate（可重复运行）：
  1. inject_frontmatter
  2. generate_index（--recursive）
  3. visualize
  4. validate-okf
  5. validate-viz-index

视角导航块 {DOC_DIR}/INDEX-GUIDE.md 第四章 → /docs-build（generate_knowledge_index.py）。

须有效 .docsconfig（含 KNOWLEDGE_TYPE、AGENT_DIR）。bundle 与默认 viz 输出取自 DOC_DIR；页面名称取自 KNOWLEDGE_TYPE。
脚本路径取自 {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts（不依赖 \$REPO_ROOT/agent/）。

环境变量:
  BUNDLE   覆盖 .docsconfig 推导的 bundle（DOC_DIR）
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "未知参数: $1（支持 --dry-run）" >&2
      exit 1
      ;;
  esac
done

# shellcheck disable=SC1091
source "$RESOLVE"
resolve_okf_paths

if [[ "$BUNDLE_OVERRIDE" -eq 0 ]]; then
  BUNDLE="$OKF_BUNDLE"
elif [[ "$BUNDLE" != "$OKF_BUNDLE" ]]; then
  echo "[okf] BUNDLE 已由环境变量覆盖为 ${BUNDLE}（.docsconfig DOC_DIR=${DOC_DIR}）" >&2
  # 覆盖 bundle 时 viz 跟随 bundle 目录名，避免写到主 KNOWLEDGE_TYPE 路径
  _okf_bundle_base="${BUNDLE##*/}"
  OKF_VIZ_OUT="${_okf_bundle_base}/viz.html"
  OKF_VIZ_NAME="${_okf_bundle_base} OKF"
  echo "[okf] OKF_VIZ_OUT 跟随 bundle → ${OKF_VIZ_OUT}" >&2
fi

OKF_DIR="${OKF_SCRIPTS:?}"
if [[ ! -d "$OKF_DIR" ]]; then
  echo "[okf] 未找到 OKF 脚本目录: ${OKF_DIR}（须 {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts；请 docs-install 建软链或 /agent-install）" >&2
  exit 1
fi

run_cmd() {
  local desc="$1"
  shift
  echo ""
  echo "=== ${desc} ==="
  echo ">>> $*"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    "$@"
  fi
}

export DOCS_OKF_REPO_ROOT="$REPO_ROOT"
cd "$REPO_ROOT"

echo "=== okf-refresh ==="
echo "REPO_ROOT:      ${REPO_ROOT}"
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
echo "=== okf-refresh 完成 ==="
