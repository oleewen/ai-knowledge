#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"
mkdir -p "$FIXTURE/.agents/skills/agent-install" "$FIXTURE/.agents/scripts"
cp -R "$ROOT_DIR/agent/skills/agent-install/scripts" "$FIXTURE/.agents/skills/agent-install/"
cp -R "$ROOT_DIR/agent/scripts/lib" "$FIXTURE/.agents/scripts/"
cp "$ROOT_DIR/agent/scripts/docs-core.sh" "$FIXTURE/.agents/scripts/"
INSTALLED="$FIXTURE/.agents/skills/agent-install/scripts/agent-install.sh"

# An unrelated tree above the installed skill must not become its implicit meta.
make_meta_fixture "$FIXTURE"
if HOME="$FIXTURE" "$BASH" "$INSTALLED" --workspace "$FIXTURE/ws" --dry-run >"$FIXTURE/out" 2>&1; then
  fail "已安装入口未传 --meta 时不能猜用上级 agent 树"
fi
assert_file_not_exists "$FIXTURE/.agents/configs"

HOME="$FIXTURE" "$BASH" "$INSTALLED" --meta "$FIXTURE/meta" --scope=k --target "$FIXTURE/project" --agents=codex --workspace "$FIXTURE/ws" >"$FIXTURE/out" 2>&1
assert_symlink_points_to "$FIXTURE/project/.codex/knowledge" "$FIXTURE/.agents/knowledge"
assert_file_not_exists "$FIXTURE/project/.docsconfig"
assert_contains 'WORK_SPACE=~/ws' "$FIXTURE/.agents/configs"
pass "安装副本显式指定元库；工程 target 不依赖或生成 .docsconfig"
