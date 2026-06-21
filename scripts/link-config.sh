#!/usr/bin/env bash
# link-config.sh — docs-link 配置层；knowledge-links 解析见 docs-core.sh

readonly LINK_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_core="${LINK_CONFIG_DIR}/../agent/scripts/docs-core.sh"
if [[ -f "$_core" ]]; then
  # shellcheck source=../agent/scripts/docs-core.sh
  source "$_core"
else
  for _bootstrap in \
    "${HOME}/.cursor/scripts/docs-core.sh" \
    "${HOME}/.trae/scripts/docs-core.sh" \
    "${HOME}/.claude/scripts/docs-core.sh"; do
    if [[ -f "$_bootstrap" ]]; then
      # shellcheck source=/dev/null
      source "$_bootstrap"
      break
    fi
  done
  if declare -f sdx_source_docs_core_from_layout >/dev/null 2>&1; then
    sdx_source_docs_core_from_layout "$LINK_CONFIG_DIR" || exit 1
  else
    printf '错误: 未找到 docs-core（中央库或 ~/.cursor/scripts/docs-core.sh）。\n' >&2
    exit 1
  fi
fi

readonly KLINK_DEFAULT_DRY_RUN='0'

validate_link_command() {
  [[ "${1:-}" =~ ^(link|unlink)$ ]]
}

normalize_target_repo_root() {
  local raw="${1:-}"
  [[ -n "$raw" ]] || return 1
  strip_trailing_slash "$(abs_path "$raw")"
}
