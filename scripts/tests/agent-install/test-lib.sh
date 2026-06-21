#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
AGENT_INSTALL_SCRIPT="$ROOT_DIR/scripts/agent-install.sh"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$*"
}

assert_file_exists() {
  local path="${1:?path is required}"
  [[ -f "$path" ]] || fail "文件不存在: $path"
}

assert_dir_exists() {
  local path="${1:?path is required}"
  [[ -d "$path" ]] || fail "目录不存在: $path"
}

assert_dir_not_exists() {
  local path="${1:?path is required}"
  [[ ! -e "$path" ]] || fail "path should not exist: $path"
}

assert_symlink_points_to() {
  local link="${1:?link is required}" expect="${2:?expect is required}"
  [[ -L "$link" ]] || fail "not a symlink: $link"
  local actual resolved_expect
  actual="$(readlink "$link" 2>/dev/null || true)"
  [[ -n "$actual" ]] || fail "readlink failed: $link"
  resolved_expect="$(cd "$(dirname "$expect")" 2>/dev/null && pwd -P)/$(basename "$expect")"
  actual="$(cd "$(dirname "$actual")" 2>/dev/null && pwd -P)/$(basename "$actual")"
  [[ "$actual" == "$resolved_expect" ]] || fail "symlink mismatch: $link -> $actual (expected $resolved_expect)"
}

new_fake_home() {
  mktemp -d "${TMPDIR:-/tmp}/agent-install-tests.XXXXXX"
}

run_agent_install() {
  local fake_home="$1"
  shift
  HOME="$fake_home" bash "$AGENT_INSTALL_SCRIPT" "$@"
}
