#!/usr/bin/env bash
# sdx-validate-bootstrap.sh — 供 .agent/skills/*/scripts/validate-*.sh source
# 位于 .agent/scripts/；优先加载同目录 sdx-doc-root.sh（方案丙：单一事实来源）。

sdx_validate_load_doc_root() {
  local script_dir="${1:?script_dir}"
  local s="" gr=""
  local boot_dir
  boot_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  s="$boot_dir/sdx-doc-root.sh"
  if [[ ! -f "$s" ]]; then
    s="$(cd "$script_dir/../../../../.agent/scripts" 2>/dev/null && pwd)/sdx-doc-root.sh"
  fi
  if [[ ! -f "$s" ]]; then
    gr="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
    [[ -n "$gr" && -f "$gr/.agent/scripts/sdx-doc-root.sh" ]] && s="$gr/.agent/scripts/sdx-doc-root.sh"
  fi
  if [[ -f "$s" ]]; then
    # shellcheck disable=SC1090
    source "$s"
  fi
  if ! declare -F sdx_resolve_repo_doc_root >/dev/null 2>&1; then
    sdx_resolve_repo_doc_root() {
      local o="${1:-}" pb="${2:-}" seg b
      [[ -z "$pb" ]] && pb="$(pwd)"
      b="$(cd "$pb" 2>/dev/null && pwd || printf '%s' "$pb")"
      if [[ -n "$o" ]]; then
        seg="${o%%/*}"
      elif [[ -n "${SDX_DOC_ROOT:-}" ]]; then
        seg="${SDX_DOC_ROOT%%/*}"
      else
        seg="docs"
      fi
      printf '%s/%s' "$b" "$seg"
    }
  fi
}
