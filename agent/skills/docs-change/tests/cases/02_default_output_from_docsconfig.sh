#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  pass "跳过（需 Bash 5+）"
  exit 0
fi

canonical_dir() {
  local p="$1"
  (cd "$p" && pwd -P)
}

TMP_DIR="$(new_tmp_dir)"
mkdir -p "$TMP_DIR/project"
PROJECT_DIR="$(canonical_dir "$TMP_DIR/project")"
APPLICATION_DIR="$PROJECT_DIR/application"
EXPECTED_OUTPUT="$APPLICATION_DIR/changelogs"
META_ENV="$EXPECTED_OUTPUT/.raw/meta.env"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$APPLICATION_DIR"
git -C "$PROJECT_DIR" init -q

cat >"$PROJECT_DIR/.docsconfig" <<EOF
DOC_ROOT=$APPLICATION_DIR
REPO_ROOT=$PROJECT_DIR
DOC_DIR=application
EOF

set +e
out="$(cd "$PROJECT_DIR" && bash "$CHANGE_SCRIPT" 2>&1)"
code=$?
set -e

[[ "$code" -eq 0 ]] || fail "有 .docsconfig 时应成功退出 (code=$code): $out"
[[ -f "$META_ENV" ]] || fail "应生成 meta.env: $META_ENV"

# shellcheck disable=SC1090
source "$META_ENV"

got="$(canonical_dir "$OUTPUT_DIR")"
want="$(canonical_dir "$EXPECTED_OUTPUT")"
[[ "$got" == "$want" ]] \
  || fail "OUTPUT_DIR 应为 DOC_ROOT/changelogs: 期望 $want 实际 $got"

pass "默认输出目录为 DOC_ROOT/changelogs（.docsconfig）"
