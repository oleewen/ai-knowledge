#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"
DRY_RUN=0 IO_DRY_RUN=0 run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=k --agents=codex --dry-run >"$FIXTURE/out" 2>&1
assert_dir_not_exists "$FIXTURE/.agents"
assert_dir_not_exists "$FIXTURE/.codex"
pass "显式 --dry-run 不受共享库同名环境变量覆盖"
