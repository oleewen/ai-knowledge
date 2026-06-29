#!/usr/bin/env bash

if [[ -n "${_SDX_SHELL_UTILS_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _SDX_SHELL_UTILS_SH_LOADED=1

sdx_nullglob_enable() {
  local -n _save_ref="${1:?save_ref is required}"
  _save_ref=1
  shopt -q nullglob && _save_ref=0
  shopt -s nullglob
}

sdx_nullglob_restore() {
  local -n _save_ref="${1:?save_ref is required}"
  if (( _save_ref == 0 )); then
    shopt -s nullglob
  else
    shopt -u nullglob
  fi
}

sdx_symlink_points_to() {
  local link="${1:?link is required}"
  local expect="${2:?expect is required}"
  local actual

  [[ -L "$link" ]] || return 1
  actual="$(readlink "$link" 2>/dev/null || true)"
  [[ -n "$actual" && "$actual" == "$expect" ]]
}
