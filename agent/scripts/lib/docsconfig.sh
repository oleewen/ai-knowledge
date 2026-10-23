#!/usr/bin/env bash
#
# lib/docsconfig.sh — .docsconfig 读写校验、bootstrap 注入当前 shell、Git 默认常量
# 依赖：lib/path.sh、backup.sh 与内部配置片段（轻量；tools 可只 source 本文件，不拖入 log-io / docs-core）
# 禁止 export WORK_SPACE / REPO_DIR / DOC_DIR / AGENT_*（仅当前 shell 赋值）
#

_DOCSCONFIG_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=path.sh
source "${_DOCSCONFIG_LIB_DIR}/path.sh"

if [[ -n "${_LIB_DOCSCONFIG_LOADED:-}" ]]; then
  unset _DOCSCONFIG_LIB_DIR
  return 0 2>/dev/null || exit 0
fi
_LIB_DOCSCONFIG_LOADED=1

DEFAULT_GIT_REPO_URL='https://github.com/oleewen/ai-knowledge.git'
DEFAULT_GIT_REF='HEAD'
SUPPORTED_KNOWLEDGE_TYPES=(application system solution company meta)

_docsconfig_info() {
  if declare -F info >/dev/null 2>&1; then
    info "$@"
  else
    printf '%s\n' "$*"
  fi
}

_docsconfig_err() {
  printf '%s\n' "$*" >&2
}

docsconfig_bootstrap_get_repo_url() {
  printf '%s' "${GIT_REPO_URL:-$DEFAULT_GIT_REPO_URL}"
}

docsconfig_bootstrap_get_ref() {
  printf '%s' "${GIT_REF:-$DEFAULT_GIT_REF}"
}

docsconfig_bootstrap_get_tmpdir() {
  local tmpdir="${TMPDIR:-/tmp}"
  [[ -d "$tmpdir" ]] || tmpdir='/tmp'
  printf '%s' "$tmpdir"
}

docsconfig_bootstrap_gen_clone_dir() {
  printf '%s/ai-knowledge-%s' "${1:?tmpdir}" "$$"
}

# shellcheck source=backup.sh
source "${_DOCSCONFIG_LIB_DIR}/backup.sh"
# shellcheck source=docsconfig-fields.sh
source "${_DOCSCONFIG_LIB_DIR}/docsconfig-fields.sh"
# shellcheck source=docsconfig-workspace.sh
source "${_DOCSCONFIG_LIB_DIR}/docsconfig-workspace.sh"
# shellcheck source=docsconfig-store.sh
source "${_DOCSCONFIG_LIB_DIR}/docsconfig-store.sh"
unset _DOCSCONFIG_LIB_DIR
