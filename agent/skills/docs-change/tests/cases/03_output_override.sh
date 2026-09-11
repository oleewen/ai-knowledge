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
CUSTOM_OUTPUT="$TMP_DIR/custom-changelogs"
META_ENV="$CUSTOM_OUTPUT/.raw/meta.env"

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
out="$(cd "$PROJECT_DIR" && bash "$CHANGE_SCRIPT" --output "$CUSTOM_OUTPUT" 2>&1)"
code=$?
set -e

[[ "$code" -eq 0 ]] || fail "--output 覆盖时应成功退出 (code=$code): $out"
[[ -f "$META_ENV" ]] || fail "应生成 meta.env: $META_ENV"

# shellcheck disable=SC1090
source "$META_ENV"

got="$(canonical_dir "$OUTPUT_DIR")"
want="$(canonical_dir "$CUSTOM_OUTPUT")"
[[ "$got" == "$want" ]] \
  || fail "OUTPUT_DIR 应等于 --output: 期望 $want 实际 $got"

pass "--output 覆盖默认 changelogs 目录"
