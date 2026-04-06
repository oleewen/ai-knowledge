#!/usr/bin/env bash
# sdx-validate-bootstrap.sh — 供 .ai/skills/*/scripts/validate-*.sh source
# 位于 .ai/skills/；加载仓库根 scripts/sdx-doc-root.sh。

sdx_validate_load_doc_root() {
  local script_dir="${1:?script_dir}"
  local s="" gr=""
  local boot_dir
  boot_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  s="$(cd "$boot_dir/../.." 2>/dev/null && pwd)/scripts/sdx-doc-root.sh"
  if [[ ! -f "$s" ]]; then
    s="$(cd "$script_dir/../../../../scripts" 2>/dev/null && pwd)/sdx-doc-root.sh"
  fi
  if [[ ! -f "$s" ]]; then
    gr="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
    [[ -n "$gr" && -f "$gr/scripts/sdx-doc-root.sh" ]] && s="$gr/scripts/sdx-doc-root.sh"
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
