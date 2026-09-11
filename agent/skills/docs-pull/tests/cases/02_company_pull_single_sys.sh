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

COMPANY="$TMP_DIR/company"
SYS="$TMP_DIR/sys-foo"
BARE="$TMP_DIR/sys-foo.bare.git"

mkdir -p "$COMPANY/docs" "$SYS/docs"
git -C "$COMPANY" init -q
git -C "$SYS" init -q

cat >"$COMPANY/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$COMPANY
DOC_DIR=docs
KNOWLEDGE_TYPE=company
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

cat >"$SYS/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$SYS
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

echo "content" >"$SYS/docs/sync-me.md"
git -C "$SYS" add .
git -C "$SYS" commit -m "init sys docs" -q
git clone --bare "$SYS" "$BARE" -q
git -C "$SYS" remote add origin "$BARE"

mkdir -p "$COMPANY/docs/system-slots"

cat >"$COMPANY/docs/knowledge-links.yaml" <<EOF
links:
  - repository: "$BARE"
    path: "$SYS"
    doc_dir: "docs"
    sys_name: "sys-foo"
    sys_label: "sys-foo"
EOF

set +e
out="$(cd "$COMPANY" && "${BASH:-bash}" "$PULL" --sys-name sys-foo 2>&1)"
code=$?
set -e

[[ "$code" -eq 0 ]] || fail "docs-pull 应成功：$out"
printf '%s\n' "$out" | grep -Fq 'SYNC_OK:' || fail "应输出 SYNC_OK"

[[ -L "$COMPANY/docs/system-slots/system-sys-foo" ]] \
  || fail "槽位应为软链"
assert_file_exists "$COMPANY/docs/system-slots/system-sys-foo/sync-me.md"
grep -Fq "$BARE" "$COMPANY/docs/system-slots/changelogs/CHANGE-LOG.md" \
  || fail "应写入 repository 作为 source"

pass "company: pull single sys symlink + changelog"
