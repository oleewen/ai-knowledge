#!/usr/bin/env bash
# link 时 repository 必填：目标仓库须有 Git remote URL
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  pass "跳过（需 Bash 5+）"
  exit 0
fi

TMP_DIR="$(new_tmp_dir)"
ROOT_DIR="$(cd "$TEST_DIR/../../../../.." && pwd)"
DOCS_LINK="$ROOT_DIR/agent/skills/docs-link/scripts/docs-link.sh"
FAKEHOME="$TMP_DIR/fakehome"
SYS_SRC="$FAKEHOME/ws/system-kb"
APP_TGT="$FAKEHOME/ws/app-no-remote"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$SYS_SRC/docs/application-slots" "$APP_TGT/docs"
printf '%s\n' 'links: []' >"$APP_TGT/docs/knowledge-links.yaml"
git -C "$SYS_SRC" init -q
git -C "$APP_TGT" init -q

cat >"$SYS_SRC/.docsconfig" <<EOF
REPO_DIR=$(basename "$SYS_SRC")
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$TMP_DIR
AGENT_DIR=agent
EOF
pin_workspace_for_repo "$SYS_SRC" "$TMP_DIR" agent

cat >"$APP_TGT/.docsconfig" <<EOF
REPO_DIR=$(basename "$APP_TGT")
DOC_DIR=docs
KNOWLEDGE_TYPE=application
AGENT_ROOT=$TMP_DIR
AGENT_DIR=agent
EOF
pin_workspace_for_repo "$APP_TGT" "$TMP_DIR" agent

set +e
out="$(cd "$SYS_SRC" && HOME="$FAKEHOME" "${BASH:-bash}" "$DOCS_LINK" --link --target "$APP_TGT" 2>&1)"
code=$?
set -e

[[ "$code" -ne 0 ]] || fail "目标无 remote 时应失败"
printf '%s\n' "$out" | grep -Fq 'repository 必填' || fail "应提示 repository 必填"

pass "repository 必填：目标无 remote 时 link 失败"

