#!/usr/bin/env bash
#
# knowledge-config.sh — 仅供 knowledge-init.sh source
#
# 职责：
# - 承载 knowledge-init 的默认值、枚举校验与规范化、路径函数、.docsconfig 工具
# - 自闭环实现；路径与 .docsconfig 工具统一复用 agent/scripts/docs-config.sh
#

readonly KNOWLEDGE_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../agent/scripts/docs-config.sh
source "${KNOWLEDGE_CONFIG_DIR}/../agent/scripts/docs-config.sh"

# =============================================================================
# § 1  版本与常量
# =============================================================================

readonly -a SDX_SUPPORTED_MODES=(standalone central)

declare -A SDX_DEFAULTS=(
  [docs_dir]='docs'
  [mode]='standalone'
)

# knowledge-init 语义默认值（供入口编排层使用）
readonly KINIT_DEFAULT_SCOPE='config'
readonly KINIT_DEFAULT_TYPE='application'
readonly KINIT_DEFAULT_MODE='standalone'

# =============================================================================
# § 2  参数校验与规范化
# =============================================================================

validate_mode() {
  [[ "${1:-}" =~ ^(standalone|central|s|c)$ ]]
}

normalize_mode() {
  case "${1:-}" in
    s|standalone) printf 'standalone' ;;
    c|central) printf 'central' ;;
    *) printf 'standalone' ;;
  esac
}

validate_type() {
  docsconfig_knowledge_type_is_valid "${1:-}"
}

normalize_type() {
  case "${1,,}" in
    application|a) printf 'application' ;;
    system|s) printf 'system' ;;
    company|c) printf 'company' ;;
    *) printf '%s' "${1:-}" ;;
  esac
}

validate_scope() {
  [[ "${1:-}" =~ ^(knowledge|k|config|c|cfg)$ ]]
}

normalize_scope() {
  case "${1:-}" in
    k|knowledge) printf 'knowledge' ;;
    c|config|cfg) printf 'config' ;;
    *) printf '%s' "${1:-}" ;;
  esac
}

cfg_default() {
  printf '%s' "${SDX_DEFAULTS[${1:-}]:-}"
}

post_init_checklist() {
  cat <<'CHECKLIST'

================================================================================
初始化完成！建议核对
================================================================================
CHECKLIST
}
