#!/usr/bin/env bash
# meta path 为 git：脏硬停；无 --ref 用 HEAD；有 --ref 用该 tip
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
ensure_test_agent_home "$TMP_DIR"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
META_ROOT="$TMP_DIR/meta"
OUT_FILE="$TMP_DIR/case03.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR" "$META_ROOT/application"
git -C "$PROJECT_DIR" init -q

cat >"$PROJECT_DIR/.docsconfig" <<EOF
DOC_ROOT=$DOCS_DIR
REPO_ROOT=$PROJECT_DIR
DOC_DIR=docs
AGENT_ROOT=~
AGENT_DIR=.agents
KNOWLEDGE_TYPE=application
EOF

# --- 初始化 meta git：main 与 feature 内容不同 ---
git -C "$META_ROOT" init -q
git -C "$META_ROOT" config user.email "test@example.com"
git -C "$META_ROOT" config user.name "docs-upgrade-test"
printf '%s\n' '# main tip' >"$META_ROOT/application/scaffold-main.md"
git -C "$META_ROOT" add application/scaffold-main.md
git -C "$META_ROOT" commit -q -m "main tip"
# 默认分支名可能是 master；统一成 main
git -C "$META_ROOT" branch -M main

git -C "$META_ROOT" checkout -q -b feature
rm -f "$META_ROOT/application/scaffold-main.md"
printf '%s\n' '# feature tip' >"$META_ROOT/application/scaffold-feat.md"
git -C "$META_ROOT" add -A
git -C "$META_ROOT" commit -q -m "feature tip"
# 停在 feature（当前 HEAD）

# 1) 无 --ref：清单须含 scaffold-feat，不含 scaffold-main
(
  cd "$PROJECT_DIR"
  bash "$DOCS_UPGRADE_SCRIPT" --dry-run --meta-path "$META_ROOT" >"$OUT_FILE" 2>&1
)
assert_contains "scaffold-feat.md" "$OUT_FILE"
assert_not_contains "scaffold-main.md" "$OUT_FILE"
assert_contains "git archive HEAD" "$OUT_FILE"

# 2) --ref main：清单须含 scaffold-main，不含 scaffold-feat
(
  cd "$PROJECT_DIR"
  bash "$DOCS_UPGRADE_SCRIPT" --dry-run --meta-path "$META_ROOT" --ref main >"$OUT_FILE" 2>&1
)
assert_contains "scaffold-main.md" "$OUT_FILE"
assert_not_contains "scaffold-feat.md" "$OUT_FILE"

# 3) 脏工作区（含 --ref）硬停
printf '%s\n' 'dirty' >"$META_ROOT/application/untracked-dirty.md"
set +e
(
  cd "$PROJECT_DIR"
  bash "$DOCS_UPGRADE_SCRIPT" --dry-run --meta-path "$META_ROOT" --ref main >"$OUT_FILE" 2>&1
)
rc=$?
set -e
[[ "$rc" -ne 0 ]] || fail "脏 meta path 应非 0 退出，实际 $rc"
assert_contains "未提交改动" "$OUT_FILE"

pass "meta git：HEAD / --ref / 脏硬停"
