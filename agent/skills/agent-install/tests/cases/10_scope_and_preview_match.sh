#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"

run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=k --agents=cursor >"$FIXTURE/out" 2>&1
run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=r --agents=codex --dry-run >"$FIXTURE/preview" 2>&1
assert_dir_not_exists "$FIXTURE/.codex"
assert_not_contains "$FIXTURE/.codex/knowledge" "$FIXTURE/preview"
assert_not_contains "$FIXTURE/.codex/references" "$FIXTURE/preview"
assert_contains "$FIXTURE/.codex/rules/item.txt -> $FIXTURE/.agents/rules/item.txt" "$FIXTURE/preview"
run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=r --agents=codex >"$FIXTURE/out" 2>&1
assert_symlink_points_to "$FIXTURE/.codex/rules/item.txt" "$FIXTURE/.agents/rules/item.txt"
assert_dir_not_exists "$FIXTURE/.codex/knowledge"
assert_dir_not_exists "$FIXTURE/.codex/references"

# Existing stores must not hide newly added source entries in the preview.
printf 'new\n' >"$FIXTURE/meta/agent/rules/new.txt"
run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=r --agents=codex --dry-run >"$FIXTURE/preview" 2>&1
assert_contains "$FIXTURE/.codex/rules/new.txt -> $FIXTURE/.agents/rules/new.txt" "$FIXTURE/preview"
assert_file_not_exists "$FIXTURE/.agents/rules/new.txt"
pass "scope 不扩链其他资源；已有安装树的预览包含新增条目且不写入"
