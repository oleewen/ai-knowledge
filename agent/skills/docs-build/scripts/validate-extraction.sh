#!/usr/bin/env bash
set -euo pipefail

# 路径只从当前消费仓的 .docsconfig 解析；Python 负责只读结构校验。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
  echo '用法: bash validate-extraction.sh [--entities-only] [--perspectives application,data,...]'
  echo '从当前目录上溯读取 .docsconfig；需要 Bash 5+、Python 3。'
  exit 0
fi
args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
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
# 元库可直接选择规范命名的四层目录；消费仓使用显式知识层。
if [[ "$layer" == meta && "$DOC_DIR" =~ ^(application|system|solution|company)$ ]]; then
  layer="$DOC_DIR"
fi
exec python3 "$SCRIPT_DIR/validate_extraction.py" \
  --repo "$(docsconfig_repo_abs)" --bundle "$DOC_DIR" --layer-scope "$layer" "${args[@]}"
