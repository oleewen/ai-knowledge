#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"
mkdir -p "$FIXTURE/bin"
for tool in dirname basename date mkdir cp mv rm ln readlink find sed tr cat; do
  ln -s "$(command -v "$tool")" "$FIXTURE/bin/$tool"
done
PATH="$FIXTURE/bin" run_agent_install "$FIXTURE" --meta "$FIXTURE/meta" --scope=s --agents=codex >"$FIXTURE/out" 2>&1
assert_file_exists "$FIXTURE/.agents/skills/demo/nested/data.txt"
assert_file_not_exists "$FIXTURE/.agents/skills/demo/README.md"
assert_file_not_exists "$FIXTURE/.agents/skills/demo/nested/readme.md"
pass "无 rsync 时仍排除各层 README"
