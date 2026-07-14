#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case04.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

APP_INDEX="$ROOT_DIR/application/index.md"
SYS_INDEX="$ROOT_DIR/system/index.md"
APP_SLOT_GLOB="$ROOT_DIR/system/application-*"
SYS_SLOT_GLOB="$ROOT_DIR/company/system-*"

[[ -f "$APP_INDEX" ]] || fail "缺少索引文件: $APP_INDEX"
[[ -f "$SYS_INDEX" ]] || fail "缺少索引文件: $SYS_INDEX"

count_glob_matches() {
  local pattern="${1:?pattern is required}"
  local -a matches=()
  shopt -s nullglob
  matches=($pattern)
  shopt -u nullglob
  printf '%s' "${#matches[@]}"
}

APP_INDEX_SUM_BEFORE="$(cksum "$APP_INDEX" | awk '{print $1":"$2}')"
SYS_INDEX_SUM_BEFORE="$(cksum "$SYS_INDEX" | awk '{print $1":"$2}')"
APP_SLOT_COUNT_BEFORE="$(count_glob_matches "$APP_SLOT_GLOB")"
SYS_SLOT_COUNT_BEFORE="$(count_glob_matches "$SYS_SLOT_GLOB")"

bash "$DOCS_INSTALL_SCRIPT" \
  --scope=knowledge \
  --mode=central \
  --type=application \
  --dry-run \
  --target "$DOCS_DIR" >"$OUT_FILE" 2>&1

APP_INDEX_SUM_AFTER="$(cksum "$APP_INDEX" | awk '{print $1":"$2}')"
SYS_INDEX_SUM_AFTER="$(cksum "$SYS_INDEX" | awk '{print $1":"$2}')"
APP_SLOT_COUNT_AFTER="$(count_glob_matches "$APP_SLOT_GLOB")"
SYS_SLOT_COUNT_AFTER="$(count_glob_matches "$SYS_SLOT_GLOB")"

[[ "$APP_INDEX_SUM_BEFORE" == "$APP_INDEX_SUM_AFTER" ]] \
  || fail "application/index.md 不应被修改"
[[ "$SYS_INDEX_SUM_BEFORE" == "$SYS_INDEX_SUM_AFTER" ]] \
  || fail "system/index.md 不应被修改"
[[ "$APP_SLOT_COUNT_BEFORE" == "$APP_SLOT_COUNT_AFTER" ]] \
  || fail "system/application-* 联邦槽位数量发生变化"
[[ "$SYS_SLOT_COUNT_BEFORE" == "$SYS_SLOT_COUNT_AFTER" ]] \
  || fail "company/system-* 联邦槽位数量发生变化"

pass "central 不触发登记副作用（dry-run）"
