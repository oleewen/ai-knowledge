#!/usr/bin/env bash
set -euo pipefail
# 公司域架构：KNOWLEDGE_TYPE=company；DOMAIN-MAP.md；DOMAIN-{BD-ID}.md（非七章 SOLUTION）

TARGET_FILE=""
ERRORS=0
WARNINGS=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --file) TARGET_FILE="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck disable=SC1091
source "$_AGENT_HOME/scripts/lib/docsconfig.sh"
docsconfig_bootstrap_validate

if [[ "${KNOWLEDGE_TYPE:-}" != "company" ]]; then
  echo "[ERROR] /sdx-domains 仅允许 KNOWLEDGE_TYPE=company；当前=${KNOWLEDGE_TYPE:-unset}"
  exit 1
fi

DOC_ROOT="$(docsconfig_resolve_doc_root)"
DOMAINS_DIR="${DOC_ROOT}/domains"
error() { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

if [[ ! -d "$DOMAINS_DIR" ]]; then
  error "domains/ 不存在: $DOMAINS_DIR"
else
  success "domains/ 存在"
fi

if [[ -n "$TARGET_FILE" ]]; then
  [[ -f "$TARGET_FILE" ]] || { error "文件不存在: $TARGET_FILE"; echo "错误: $ERRORS"; exit 1; }
  grep -q '^id:' "$TARGET_FILE" || error "缺 frontmatter id: $TARGET_FILE"
else
  [[ -f "$DOMAINS_DIR/DOMAIN-MAP.md" ]] && success "DOMAIN-MAP.md" || error "缺 DOMAIN-MAP.md"
  n=$(find "$DOMAINS_DIR" -name 'DOMAIN-*.md' ! -name 'DOMAIN-MAP.md' 2>/dev/null | wc -l | tr -d ' ')
  success "DOMAIN-*.md × ${n}"
fi

echo "错误: ${ERRORS}"
[[ "$ERRORS" -eq 0 ]]
