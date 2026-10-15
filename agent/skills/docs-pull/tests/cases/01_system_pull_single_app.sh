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
REPO_DIR=$(basename "$SYSTEM")
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$TMP_DIR/agent-home
AGENT_DIR=.agents
EOF
pin_workspace_for_repo "$SYSTEM" "$TMP_DIR/agent-home" .agents

cat >"$APP/.docsconfig" <<EOF
REPO_DIR=$(basename "$APP")
DOC_DIR=docs
KNOWLEDGE_TYPE=application
AGENT_ROOT=$TMP_DIR/agent-home
AGENT_DIR=.agents
EOF
pin_workspace_for_repo "$APP" "$TMP_DIR/agent-home" .agents

echo "content" >"$APP/docs/sync-me.md"
git -C "$APP" add .
git -C "$APP" commit -m "init app docs" -q
git clone --bare "$APP" "$BARE" -q
git -C "$APP" remote add origin "$BARE"

mkdir -p "$SYSTEM/docs/application-slots"
# 旧真目录槽位：应被静默删除后改建软链
mkdir -p "$SYSTEM/docs/application-slots/application-app-foo"
echo "# old" >"$SYSTEM/docs/application-slots/application-app-foo/legacy.txt"

cat >"$SYSTEM/docs/knowledge-links.yaml" <<EOF
links:
  - type: child
    repository: "$BARE"
    path: "$APP"
    dir: "docs"
    name: "app-foo"
    label: "app-foo"
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
[[ ! -e "$SYSTEM/docs/application-slots/changelogs" ]] \
  || fail "不应再创建 application-slots/changelogs"

pass "system: pull single app symlink + git trace"
