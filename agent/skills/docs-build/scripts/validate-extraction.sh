#!/usr/bin/env bash
set -euo pipefail

# 路径只从当前消费仓的 .docsconfig 解析；Python 负责只读结构校验。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
  echo '用法: bash validate-extraction.sh [--entities-only] [--perspectives application,data,...] [--layer LAYER --bundle PATH]'
  echo '从当前目录上溯读取 .docsconfig；需要 Bash 5+、Python 3。'
  exit 0
fi
args=()
explicit_layer=""
explicit_bundle=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --layer|--bundle)
      [[ $# -ge 2 ]] || { echo "缺少 $1 值" >&2; exit 1; }
      if [[ "$1" == --layer ]]; then explicit_layer="$2"; else explicit_bundle="$2"; fi
      shift 2 ;;
    --entities-only) args+=("$1"); shift ;;
    --perspectives)
      [[ $# -ge 2 ]] || { echo '缺少 --perspectives 值' >&2; exit 1; }
      args+=("$1" "$2"); shift 2 ;;
    --perspectives=*) args+=("$1"); shift ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done
# shellcheck source=../../../scripts/lib/docsconfig.sh
source "$SCRIPT_DIR/../../../scripts/lib/docsconfig.sh"
docsconfig_bootstrap_validate
layer="${KNOWLEDGE_TYPE:-}"
if [[ "$layer" == meta && ( -z "$explicit_layer" || -z "$explicit_bundle" ) ]]; then
  echo '元库必须显式指定 --layer 与 --bundle' >&2
  exit 1
fi
export PYTHONDONTWRITEBYTECODE=1
export KNOWLEDGE_VALIDATION_BASH="$BASH"
exec python3 "$SCRIPT_DIR/validate_extraction.py" \
  --repo "$(docsconfig_repo_abs)" --bundle "${explicit_bundle:-$DOC_DIR}" --layer-scope "${explicit_layer:-$layer}" "${args[@]}"
