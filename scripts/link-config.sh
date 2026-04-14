#!/usr/bin/env bash
#
# link-config.sh — 仅供 knowledge-link.sh source
#
# 职责：
# - 承载 knowledge-link 的默认值、参数校验、路径函数、.docsconfig 读入工具
# - 自闭环实现；路径与 .docsconfig 工具统一复用 agent/scripts/docs-config.sh
#

readonly LINK_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../agent/scripts/docs-config.sh
source "${LINK_CONFIG_DIR}/../agent/scripts/docs-config.sh"

# =============================================================================
# § 1  常量与校验（SDX_SUPPORTED_KNOWLEDGE_TYPES 见已 source 的 docs-config.sh）
# =============================================================================

readonly KLINK_DEFAULT_DRY_RUN='0'

validate_link_command() {
  [[ "${1:-}" =~ ^(link|unlink)$ ]]
}

normalize_target_repo_root() {
  local raw="${1:-}"
  [[ -n "$raw" ]] || return 1
  local p
  p="$(abs_path "$raw")"
  p="$(strip_trailing_slash "$p")"
  printf '%s\n' "$p"
}

