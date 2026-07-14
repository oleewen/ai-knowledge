#!/usr/bin/env bash
# docs-config.sh — 仅供 docs-install.sh source（docs-install 配置层 + docs-core）

if [[ -n "${_SDX_DOCS_CONFIG_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _SDX_DOCS_CONFIG_SH_LOADED=1

if ! declare -p DOCS_CONFIG_DIR >/dev/null 2>&1; then
  readonly DOCS_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
# shellcheck source=../agent/scripts/docs-core.sh
source "${DOCS_CONFIG_DIR}/../agent/scripts/docs-core.sh"

readonly -a SDX_SUPPORTED_MODES=(standalone central)

declare -A SDX_DEFAULTS=(
  [docs_dir]='docs'
  [mode]='standalone'
)

readonly KINIT_DEFAULT_SCOPE='k'
readonly KINIT_DEFAULT_TYPE='application'
readonly KINIT_DEFAULT_MODE='standalone'

validate_mode() { [[ "${1:-}" =~ ^(standalone|central|s|c)$ ]]; }

normalize_mode() {
  case "${1:-}" in
    s|standalone) printf 'standalone' ;;
    c|central) printf 'central' ;;
    *) printf 'standalone' ;;
  esac
}

validate_type() { docsconfig_knowledge_type_is_valid "${1:-}"; }

normalize_type() {
  case "${1,,}" in
    application|a) printf 'application' ;;
    system|s) printf 'system' ;;
    company|c) printf 'company' ;;
    *) printf '%s' "${1:-}" ;;
  esac
}

validate_scope() { [[ "${1:-}" =~ ^(knowledge|k|config|c|cfg)$ ]]; }

normalize_scope() {
  case "${1:-}" in
    k|knowledge) printf 'knowledge' ;;
    c|config|cfg) printf 'config' ;;
    *) printf '%s' "${1:-}" ;;
  esac
}

cfg_default() { printf '%s' "${SDX_DEFAULTS[${1:-}]:-}"; }

post_init_checklist() {
  local docs_abs="${1:-}"
  cat <<'CHECKLIST'

================================================================================
初始化完成！建议核对
================================================================================
CHECKLIST
  [[ -n "$docs_abs" ]] && printf '  文档目录（绝对路径）: %s\n' "$docs_abs"
}
