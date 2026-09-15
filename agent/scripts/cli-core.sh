#!/usr/bin/env bash
#
# cli-core.sh — CLI 参数校验小工具（供 docs-install / agent-install 等 source）
# 依赖：调用方须先提供 sdx_error（通常经 docs-core.sh / *-config.sh）
# 幂等：可重复 source（_SDX_CLI_CORE_SH_LOADED）
#

if [[ -n "${_SDX_CLI_CORE_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _SDX_CLI_CORE_SH_LOADED=1

# 校验 flag 后的值非空；空则 sdx_error 退出
sdx_cli_require_value() {
  local flag="${1:?flag is required}"
  local value="${2-}"
  [[ -n "$value" ]] || sdx_error "缺少 ${flag} 值"
}

# 拒绝未知参数；hint 默认指向 -h/--help
sdx_cli_unknown_arg() {
  local arg="${1:?arg is required}"
  local hint="${2:-使用 -h 或 --help 查看帮助}"
  sdx_error "未知参数: ${arg}（${hint}）"
}
