#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  pass "跳过（需 Bash 5+）"
  exit 0
fi

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$PROJECT_DIR"
git -C "$PROJECT_DIR" init -q

out="$(cd "$PROJECT_DIR" && bash "$CHANGE_SCRIPT" --dry-run 2>&1)"

printf '%s\n' "$out" | grep -Fq 'dry-run' || fail "应输出 dry-run 预演提示"
printf '%s\n' "$out" | grep -Fq '.docsconfig' || fail "应提示缺少 .docsconfig"
[[ ! -d "$PROJECT_DIR/changelogs" ]] || fail "dry-run 不应创建 changelogs"

pass "无 .docsconfig + --dry-run 时仅预演"
