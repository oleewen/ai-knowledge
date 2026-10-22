#!/usr/bin/env bash
set -euo pipefail

# OKF bundle 校验入口。须有效 .docsconfig（含 KNOWLEDGE_TYPE、AGENT_DIR）。
# 用法: bash {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts/okf-validate.sh [--bundle NAME]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVE="${SCRIPT_DIR}/resolve-okf-paths.sh"

BUNDLE="${BUNDLE:-}"

usage() {
  cat <<EOF
用法: bash {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts/okf-validate.sh [--bundle NAME]

校验 OKF bundle（frontmatter、id、链接、index 条目）。
bundle 与默认 viz 输出取自 .docsconfig 的 DOC_DIR；KNOWLEDGE_TYPE、AGENT_DIR 必填。
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

cd "$repo_abs" || exit 1
export DOCS_OKF_REPO_ABS="$repo_abs"
export PYTHONDONTWRITEBYTECODE=1

echo "=== validate-okf ==="
echo "repo_abs:      ${repo_abs}"
echo "DOC_DIR:        ${DOC_DIR}"
echo "AGENT_DIR:      ${AGENT_DIR}"
echo "OKF_SCRIPTS:    ${OKF_DIR}"
echo "KNOWLEDGE_TYPE: ${KNOWLEDGE_TYPE}"
echo "BUNDLE:         ${BUNDLE}"
echo "OKF_VIZ_OUT:    ${OKF_VIZ_OUT}"
echo ""

python3 "$OKF_DIR/validate_bundle.py" --bundle "$BUNDLE" --repo "$repo_abs"
