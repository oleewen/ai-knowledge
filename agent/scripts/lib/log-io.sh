#!/usr/bin/env bash
#
# lib/log-io.sh — 日志与文件 IO 兼容门面、CLI 参数校验
# 依赖：lib/path.sh（abs_path / strip_trailing_slash）
#

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=path.sh
source "${_LIB_DIR}/path.sh"

if [[ -n "${_LIB_LOG_IO_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
# 不可 readonly：docs-core 换根重载时须 unset 后重新加载
_LIB_LOG_IO_LOADED=1

# shellcheck source=bash.sh
source "${_LIB_DIR}/bash.sh"

# shellcheck source=logging.sh
source "${_LIB_DIR}/logging.sh"
# shellcheck source=file-io.sh
source "${_LIB_DIR}/file-io.sh"
# shellcheck source=backup.sh
source "${_LIB_DIR}/backup.sh"

# 校验 flag 后的值非空；空则 error 退出
cli_require_value() {
  local flag="${1:?flag is required}"
  local value="${2-}"
  [[ -n "$value" ]] || error "缺少 ${flag} 值"
}

# 拒绝未知参数；hint 默认指向 -h/--help
cli_unknown_arg() {
  local arg="${1:?arg is required}"
  local hint="${2:-使用 -h 或 --help 查看帮助}"
  error "未知参数: ${arg}（${hint}）"
}
