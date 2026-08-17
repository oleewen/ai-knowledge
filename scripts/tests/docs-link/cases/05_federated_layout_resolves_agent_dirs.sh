#!/usr/bin/env bash
# 联邦仓无 agent/scripts：须经 HOME/.cursor + .docsconfig AGENT_* 解析 docs-core（nameref 不得读空）
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../docs-install/test-lib.sh
source "$TEST_DIR/../../docs-install/test-lib.sh"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  pass "跳过（需 Bash 5+）"
  exit 0
fi

TMP_DIR="$(new_tmp_dir)"
ROOT_DIR="$(cd "$TEST_DIR/../../../.." && pwd)"
CORE="$ROOT_DIR/agent/scripts/docs-core.sh"
FAKE_HOME="$TMP_DIR/home"
SRC="$TMP_DIR/src"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$FAKE_HOME/.agents/scripts" "$FAKE_HOME/.cursor/scripts" "$SRC/scripts" "$SRC/docs"
cp "$CORE" "$FAKE_HOME/.agents/scripts/docs-core.sh"
ln -s "$FAKE_HOME/.agents/scripts/docs-core.sh" "$FAKE_HOME/.cursor/scripts/docs-core.sh"
cp "$ROOT_DIR/scripts/docs-link.sh" "$SRC/scripts/docs-link.sh"
cp "$ROOT_DIR/scripts/link-config.sh" "$SRC/scripts/link-config.sh"
chmod +x "$SRC/scripts/docs-link.sh"
git -C "$SRC" init -q

cat >"$SRC/.docsconfig" <<EOF
DOC_ROOT=~/workspaces/src/docs
REPO_ROOT=~/workspaces/src
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=~
AGENT_DIRS=".cursor"
EOF

# 与旧 layout 调用方同名的变量不得被 nameref 读空（单独 bash，避免污染本进程）
"${BASH:-bash}" -c '
set -euo pipefail
source "$1"
raw_ar=""
raw_ads=""
_cfg_dr=""
_cfg_rr=""
_cfg_dd=""
docsconfig_read_into "$2" _cfg_dr _cfg_rr _cfg_dd raw_ar raw_ads
[[ -n "$raw_ar" ]]
[[ "$raw_ads" == ".cursor" ]]
' _ "$CORE" "$SRC/.docsconfig" || fail "docsconfig_read_into 同名 raw_ar/raw_ads 应读出 AGENT_ROOT 与 .cursor"

set +e
out="$(
  cd "$SRC" && HOME="$FAKE_HOME" "${BASH:-bash}" "$SRC/scripts/docs-link.sh" --help 2>&1
)"
code=$?
set -e

[[ "$code" -eq 0 ]] || fail "联邦布局 docs-link --help 应成功，实际 exit=$code 输出: $out"
printf '%s\n' "$out" | grep -Fq 'AGENT_ROOT/AGENT_DIRS 下均未找到' && fail "不应再误报未安装 docs-core"
printf '%s\n' "$out" | grep -Fq 'cannot unset' && fail "不应 unset 只读哨兵失败"
printf '%s\n' "$out" | grep -Eq '用法:.*docs-link' || fail "stdout 应为用法说明，实际: $out"

pass "联邦仓经 AGENT_DIRS=.cursor 解析 docs-core"
