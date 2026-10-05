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
SLN="$TMP_DIR/sln-foo"
BARE="$TMP_DIR/sln-foo.bare.git"

mkdir -p "$COMPANY/docs" "$SLN/docs"
git -C "$COMPANY" init -q
git -C "$SLN" init -q

cat >"$COMPANY/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$COMPANY
DOC_DIR=docs
KNOWLEDGE_TYPE=company
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF

cat >"$SLN/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$SLN
DOC_DIR=docs
KNOWLEDGE_TYPE=solution
AGENT_ROOT=$ROOT_DIR
AGENT_DIR=agent
EOF

echo "content" >"$SLN/docs/sync-me.md"
git -C "$SLN" add .
git -C "$SLN" commit -m "init sln docs" -q
git clone --bare "$SLN" "$BARE" -q
git -C "$SLN" remote add origin "$BARE"

mkdir -p "$COMPANY/docs/solution-slots"

cat >"$COMPANY/docs/knowledge-links.yaml" <<EOF
links:
  - repository: "$BARE"
    path: "$SLN"
    doc_dir: "docs"
    solution_name: "sln-foo"
    solution_label: "sln-foo"
EOF

set +e
out="$(cd "$COMPANY" && "${BASH:-bash}" "$PULL" --sln-name sln-foo 2>&1)"
code=$?
set -e

[[ "$code" -eq 0 ]] || fail "docs-pull 应成功：$out"
printf '%s\n' "$out" | grep -Fq 'SYNC_OK:' || fail "应输出 SYNC_OK"

[[ -L "$COMPANY/docs/solution-slots/solution-sln-foo" ]] \
  || fail "槽位应为软链"
assert_file_exists "$COMPANY/docs/solution-slots/solution-sln-foo/sync-me.md"
printf '%s\n' "$out" | grep -Fq "source=$BARE" || fail "SYNC_OK 应含 source"
printf '%s\n' "$out" | grep -Eq 'commit=[0-9a-f]+' || fail "SYNC_OK 应含 commit"
assert_file_exists "$COMPANY/docs/solution-slots/changelogs/ARCHIVE-LOG.md"

pass "company: pull single solution symlink + git trace"
