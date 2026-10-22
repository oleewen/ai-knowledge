#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"
mkdir -p "$FIXTURE/project/.codex/rules"
printf 'keep me\n' >"$FIXTURE/project/.codex/rules/item.txt"
ln -s "$FIXTURE/missing" "$FIXTURE/project/.codex/rules/other.txt"
printf 'other\n' >"$FIXTURE/meta/agent/rules/other.txt"
run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=r --target "$FIXTURE/project" --agents=codex >"$FIXTURE/out" 2>&1
assert_symlink_points_to "$FIXTURE/project/.codex/rules/item.txt" "$FIXTURE/.agents/rules/item.txt"
assert_symlink_points_to "$FIXTURE/project/.codex/rules/other.txt" "$FIXTURE/.agents/rules/other.txt"
BACKUP="$(find "$FIXTURE/project/.docs-init" -type f -name item.txt -print)"
assert_contains 'keep me' "$BACKUP"
LINK_BACKUP="$(find "$FIXTURE/project/.docs-init" -type l -name other.txt -print)"
[[ "$(readlink "$LINK_BACKUP")" == "$FIXTURE/missing" ]] || fail "必须备份断链本身"
BEFORE="$(find "$FIXTURE/project/.docs-init" -print | sort)"
run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=r --target "$FIXTURE/project" --agents=codex >"$FIXTURE/out" 2>&1
[[ "$(find "$FIXTURE/project/.docs-init" -print | sort)" == "$BEFORE" ]] || fail "重入不应重复备份正确软链"
pass "文件与断链冲突有备份；重复安装不备份正确软链"
