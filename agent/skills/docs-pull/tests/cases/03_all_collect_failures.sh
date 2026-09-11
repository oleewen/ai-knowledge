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
APP_OK="$TMP_DIR/app-ok"
APP_BAD="$TMP_DIR/app-bad"
BARE_OK="$TMP_DIR/app-ok.bare.git"

mkdir -p "$SYSTEM/docs" "$APP_OK/docs" "$APP_BAD/docs"
git -C "$SYSTEM" init -q
git -C "$APP_OK" init -q
git -C "$APP_BAD" init -q

cat >"$SYSTEM/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$SYSTEM
DOC_DIR=docs
KNOWLEDGE_TYPE=system
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

cat >"$APP_OK/.docsconfig" <<EOF
DOC_ROOT=docs
REPO_ROOT=$APP_OK
DOC_DIR=docs
KNOWLEDGE_TYPE=application
AGENT_ROOT=$ROOT_DIR/agent
AGENT_DIRS=.cursor
EOF

echo "content" >"$APP_OK/docs/sync-me.md"
git -C "$APP_OK" add . && git -C "$APP_OK" commit -m "ok" -q
git clone --bare "$APP_OK" "$BARE_OK" -q
git -C "$APP_OK" remote add origin "$BARE_OK"

git -C "$APP_BAD" remote add origin "https://example.com/org/app-bad-OTHER.git"
# APP_BAD：origin 与 links.repository 不匹配 → 失败

mkdir -p "$SYSTEM/docs/application-slots"

cat >"$SYSTEM/docs/knowledge-links.yaml" <<EOF
links:
  - repository: "$BARE_OK"
    path: "$APP_OK"
    doc_dir: "docs"
    app_name: "app-ok"
    app_label: "app-ok"
  - repository: "https://example.com/org/app-bad.git"
    path: "$APP_BAD"
    doc_dir: "docs"
    app_name: "app-bad"
    app_label: "app-bad"
EOF

set +e
out="$(cd "$SYSTEM" && "${BASH:-bash}" "$PULL" --all 2>&1)"
code=$?
set -e

[[ "$code" -ne 0 ]] || fail "--all 有失败时应 exit 1"
printf '%s\n' "$out" | grep -Fq 'FAILED:' || fail "应输出失败清单"
assert_file_exists "$SYSTEM/docs/application-slots/application-app-ok/sync-me.md"

pass "--all 汇总失败并整体失败"
