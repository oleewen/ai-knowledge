#!/usr/bin/env bash
# lib/bash.sh — Bash 版本守卫；供脚本或共享库最早加载。

if [[ -n "${_LIB_BASH_GUARD_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
_LIB_BASH_GUARD_LOADED=1

MIN_BASH_VERSION=5

require_bash5() {
  if (( ${BASH_VERSINFO[0]:-0} < MIN_BASH_VERSION )); then
    printf '[FATAL] 需要 Bash %s+，当前版本: %s\n' "$MIN_BASH_VERSION" "$BASH_VERSION" >&2
    exit 1
  fi
}

require_bash5
