#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../../docs-install/tests/test-lib.sh
source "$TEST_DIR/../../../docs-install/tests/test-lib.sh"

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  pass "跳过（需 Bash 5+）"
  exit 0
fi

TMP_DIR="$(new_tmp_dir)"
ROOT_DIR="$(cd "$TEST_DIR/../../../../.." && pwd)"
PULL="$ROOT_DIR/agent/skills/docs-pull/scripts/pull-slots.sh"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

SOLUTION="$TMP_DIR/solution"
SYS="$TMP_DIR/sys-foo"
BARE="$TMP_DIR/sys-foo.bare.git"

mkdir -p "$SOLUTION/docs" "$SYS/docs"
git -C "$SOLUTION" init -q
git -C "$SYS" init -q

cat >"$SOLUTION/.docsconfig" <<EOF
REPO_DIR=$(basename "$SOLUTION")
DOC_DIR=docs
KNOWLEDGE_TYPE=solution
AGENT_ROOT=$TMP_DIR/agent-home
AGENT_DIR=.agents
EOF
pin_workspace_for_repo "$SOLUTION" "$TMP_DIR/agent-home" .agents

cat >"$SYS/.docsconfig" <<EOF
REPO_DIR=$(basename "$SYS")
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$TMP_DIR/agent-home
AGENT_DIR=.agents
EOF
pin_workspace_for_repo "$SYS" "$TMP_DIR/agent-home" .agents

echo "content" >"$SYS/docs/sync-me.md"
git -C "$SYS" add .
git -C "$SYS" commit -m "init sys docs" -q
git clone --bare "$SYS" "$BARE" -q
git -C "$SYS" remote add origin "$BARE"

mkdir -p "$SOLUTION/docs/system-slots"

cat >"$SOLUTION/docs/knowledge-links.yaml" <<EOF
links:
  - type: child
    repository: "$BARE"
    path: "\${WORK_SPACE}/$(basename "$SYS")"
    dir: "docs"
    name: "sys-foo"
    label: "sys-foo"
EOF

set +e
out="$(cd "$SOLUTION" && "${BASH:-bash}" "$PULL" --sys-name sys-foo 2>&1)"
code=$?
set -e

[[ "$code" -eq 0 ]] || fail "docs-pull 应成功：$out"
printf '%s\n' "$out" | grep -Fq 'SYNC_OK:' || fail "应输出 SYNC_OK"
[[ -L "$SOLUTION/docs/system-slots/system-sys-foo" ]] \
  || fail "槽位应为软链"
assert_file_exists "$SOLUTION/docs/system-slots/system-sys-foo/sync-me.md"

pass "solution: pull single sys symlink + git trace"
