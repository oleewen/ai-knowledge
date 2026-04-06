#!/usr/bin/env bash
# sdx-validate-bootstrap.sh — 供 .ai/skills/*/scripts/validate-*.sh source
# 位于 .ai/scripts/；优先加载同目录 sdx-doc-root.sh（方案丙：单一事实来源）。

sdx_validate_load_doc_root() {
  local script_dir="${1:?script_dir}"
  local s="" gr=""
  local boot_dir
  boot_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  s="$boot_dir/sdx-doc-root.sh"
  if [[ ! -f "$s" ]]; then
    s="$(cd "$script_dir/../../../../.ai/scripts" 2>/dev/null && pwd)/sdx-doc-root.sh"
  fi
  if [[ ! -f "$s" ]]; then
    gr="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
    [[ -n "$gr" && -f "$gr/.ai/scripts/sdx-doc-root.sh" ]] && s="$gr/.ai/scripts/sdx-doc-root.sh"
  fi
  if [[ -f "$s" ]]; then
    # shellcheck disable=SC1090
    source "$s"
  fi
  if ! declare -F sdx_resolve_doc_root_segment >/dev/null 2>&1; then
    sdx_resolve_doc_root_segment() {
      local o="${1:-}"
      [[ -n "$o" ]] && { printf '%s' "${o%%/*}"; return; }
      [[ -n "${SDX_DOC_ROOT:-}" ]] && { printf '%s' "${SDX_DOC_ROOT%%/*}"; return; }
      printf 'docs'
    }
  fi
}
