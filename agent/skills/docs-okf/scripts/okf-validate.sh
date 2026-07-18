#!/usr/bin/env bash
set -euo pipefail

# OKF bundle 校验入口。须有效 .docsconfig（含 KNOWLEDGE_TYPE）。
# 用法: bash agent/skills/docs-okf/scripts/okf-validate.sh [--bundle NAME]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVE="${SCRIPT_DIR}/resolve-okf-paths.sh"

BUNDLE="${BUNDLE:-}"
BUNDLE_OVERRIDE=0
[[ -n "$BUNDLE" ]] && BUNDLE_OVERRIDE=1

usage() {
  cat <<EOF
用法: bash agent/skills/docs-okf/scripts/okf-validate.sh [--bundle NAME]

校验 OKF bundle（frontmatter、full_id、链接、index 条目）。
bundle 默认取自 .docsconfig 的 DOC_DIR；KNOWLEDGE_TYPE 必填。

环境变量:
  BUNDLE   覆盖 .docsconfig 推导的 bundle（DOC_DIR）
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bundle)
      [[ $# -ge 2 ]] || { echo "缺少 --bundle 参数值" >&2; exit 1; }
      BUNDLE="$2"
      BUNDLE_OVERRIDE=1
      shift 2
      ;;
    --bundle=*)
      BUNDLE="${1#*=}"
      BUNDLE_OVERRIDE=1
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

# shellcheck disable=SC1091
source "$RESOLVE"
resolve_okf_paths

if [[ "$BUNDLE_OVERRIDE" -eq 0 ]]; then
  BUNDLE="$OKF_BUNDLE"
elif [[ "$BUNDLE" != "$OKF_BUNDLE" ]]; then
  echo "[okf] BUNDLE 已由 CLI/环境变量覆盖为 ${BUNDLE}（.docsconfig DOC_DIR=${DOC_DIR}）" >&2
  # 覆盖 bundle 时 viz 跟随 bundle 目录名（与 okf-indexing.sh 一致）
  _okf_bundle_base="${BUNDLE##*/}"
  OKF_VIZ_OUT="${_okf_bundle_base}/viz.html"
  OKF_VIZ_NAME="${_okf_bundle_base} OKF"
  echo "[okf] OKF_VIZ_OUT 跟随 bundle → ${OKF_VIZ_OUT}" >&2
fi

cd "$REPO_ROOT" || exit 1

echo "=== validate-okf ==="
echo "REPO_ROOT:      ${REPO_ROOT}"
echo "DOC_DIR:        ${DOC_DIR}"
echo "KNOWLEDGE_TYPE: ${KNOWLEDGE_TYPE}"
echo "BUNDLE:         ${BUNDLE}"
echo "OKF_VIZ_OUT:    ${OKF_VIZ_OUT}"
echo ""

python3 "$REPO_ROOT/agent/skills/docs-okf/scripts/validate_bundle.py" --bundle "$BUNDLE" --repo "$REPO_ROOT"
