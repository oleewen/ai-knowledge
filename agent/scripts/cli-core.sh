#!/usr/bin/env bash

if [[ -n "${_SDX_CLI_CORE_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _SDX_CLI_CORE_SH_LOADED=1

sdx_cli_require_value() {
  local flag="${1:?flag is required}"
  local value="${2-}"
  [[ -n "$value" ]] || sdx_error "缺少 ${flag} 值"
}

sdx_cli_unknown_arg() {
  local arg="${1:?arg is required}"
  local hint="${2:-使用 -h 或 --help 查看帮助}"
  sdx_error "未知参数: ${arg}（${hint}）"
}
