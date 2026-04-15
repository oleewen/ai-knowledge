#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
DOCS_INSTALL_SCRIPT="$ROOT_DIR/scripts/docs-install.sh"
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

assert_file_not_exists() {
  local path="${1:?path is required}"
  [[ ! -f "$path" ]] || fail "文件不应存在: $path"
}

assert_contains() {
  local needle="${1:?needle is required}"
  local path="${2:?path is required}"
  rg --fixed-strings "$needle" "$path" >/dev/null \
    || fail "未命中内容: $needle ($path)"
}

assert_not_contains() {
  local needle="${1:?needle is required}"
  local path="${2:?path is required}"
  if rg --fixed-strings "$needle" "$path" >/dev/null 2>&1; then
    fail "命中不应出现内容: $needle ($path)"
  fi
}

new_tmp_dir() {
  mktemp -d "${TMPDIR:-/tmp}/docs-install-tests.XXXXXX"
}
