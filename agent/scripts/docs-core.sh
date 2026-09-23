#!/usr/bin/env bash
#
# docs-core.sh — 共享库聚合入口（实现在 lib/）
# 供 *-config.sh / bootstrap / 联邦布局按文件名解析；IDE home 仍查找本文件名。
#
# 换根重载契约：调用方先 unset _AGENT_SHARED_DOCS_CONFIG_LOADED，再 source 本文件；
# 本文件仅在哨兵未置位时清空子模块哨兵并重新加载 lib/*（见 resolve.sh）。
#

_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_LIB_DIR="${_SCRIPTS_DIR}/lib"

# path 无哨兵：每次 source 刷新（联邦换根）
# shellcheck source=lib/path.sh
source "${_LIB_DIR}/path.sh"

if [[ -n "${_AGENT_SHARED_DOCS_CONFIG_LOADED:-}" ]]; then
  return 0
fi
# 不可 readonly：联邦仓会按 AGENT_* 再 source 另一份副本，须能 unset 后重新加载。
_AGENT_SHARED_DOCS_CONFIG_LOADED=1

# 换根重载时允许子模块再次执行
unset \
  _LIB_LOG_IO_LOADED \
  _LIB_GIT_REMOTE_LOADED \
  _LIB_DOCSCONFIG_LOADED \
  _LIB_AGENTS_LOADED \
  _LIB_AGENT_LAYOUT_LOADED \
  _LIB_REWRITE_LOADED \
  _LIB_RESOLVE_LOADED \
  _LIB_KNOWLEDGE_LINKS_LOADED \
  _LIB_SLOT_SOFTLINK_LOADED \
  2>/dev/null || true

# shellcheck source=lib/log-io.sh
source "${_LIB_DIR}/log-io.sh"
# shellcheck source=lib/git-remote.sh
source "${_LIB_DIR}/git-remote.sh"
# shellcheck source=lib/docsconfig.sh
source "${_LIB_DIR}/docsconfig.sh"
# shellcheck source=lib/agents.sh
source "${_LIB_DIR}/agents.sh"
# shellcheck source=lib/agent-layout.sh
source "${_LIB_DIR}/agent-layout.sh"
# shellcheck source=lib/rewrite.sh
source "${_LIB_DIR}/rewrite.sh"
# shellcheck source=lib/resolve.sh
source "${_LIB_DIR}/resolve.sh"
# shellcheck source=lib/knowledge-links.sh
source "${_LIB_DIR}/knowledge-links.sh"
# shellcheck source=lib/slot-softlink.sh
source "${_LIB_DIR}/slot-softlink.sh"
