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

SYSTEM="$TMP_DIR/system"
APP="$TMP_DIR/app-foo"
BARE="$TMP_DIR/app-foo.bare.git"

mkdir -p "$SYSTEM/docs" "$APP/docs"
git -C "$SYSTEM" init -q
git -C "$APP" init -q

cat >"$SYSTEM/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$SYSTEM
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

cat >"$APP/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$APP
DOC_DIR=docs
KNOWLEDGE_TYPE=application
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

echo "content" >"$APP/docs/sync-me.md"
git -C "$APP" add .
git -C "$APP" commit -m "init app docs" -q
git clone --bare "$APP" "$BARE" -q
git -C "$APP" remote add origin "$BARE"

mkdir -p "$SYSTEM/docs/application-slots"
# 旧真目录槽位：应被静默迁移为软链
mkdir -p "$SYSTEM/docs/application-slots/application-app-foo/changelogs"
echo "# old archive" >"$SYSTEM/docs/application-slots/application-app-foo/changelogs/ARCHIVE-LOG.md"

cat >"$SYSTEM/docs/knowledge-links.yaml" <<EOF
links:
  - repository: "$BARE"
    path: "$APP"
    doc_dir: "docs"
    app_name: "app-foo"
    app_label: "app-foo"
EOF

set +e
out="$(cd "$SYSTEM" && "${BASH:-bash}" "$PULL" --app app-foo 2>&1)"
code=$?
set -e

[[ "$code" -eq 0 ]] || fail "docs-pull 应成功：$out"
printf '%s\n' "$out" | grep -Fq 'SYNC_OK:' || fail "应输出 SYNC_OK"
printf '%s\n' "$out" | grep -Fq "source=$BARE" || fail "SYNC_OK 应含 source"
printf '%s\n' "$out" | grep -Eq 'commit=[0-9a-f]+' || fail "SYNC_OK 应含 commit"

[[ -L "$SYSTEM/docs/application-slots/application-app-foo" ]] \
  || fail "槽位应为软链"
assert_file_exists "$SYSTEM/docs/application-slots/application-app-foo/sync-me.md"
assert_file_exists "$SYSTEM/docs/application-slots/changelogs/ARCHIVE-LOG.md"
grep -Fq 'migrated_from: app-foo' "$SYSTEM/docs/application-slots/changelogs/ARCHIVE-LOG.md" \
  || fail "应合并旧槽位 ARCHIVE-LOG"

pass "system: pull single app symlink + git trace"
