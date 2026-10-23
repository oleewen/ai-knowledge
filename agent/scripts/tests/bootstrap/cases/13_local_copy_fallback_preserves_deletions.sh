#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
SOURCE="$FAKE_HOME/source"
SNAPSHOT="$FAKE_HOME/snapshot"
git clone --quiet --local "$ROOT_DIR" "$SOURCE"
rm "$SOURCE/README.md"
printf 'local addition\n' >"$SOURCE/local-note"
# 仅加载 bootstrap 函数，隔离调用真实本地快照逻辑。
source <(sed '$d' "$DOCS_BOOTSTRAP_SCRIPT")
command() {
  if [[ "$*" == '-v rsync' ]]; then return 1; fi
  builtin command "$@"
}
bs_clone_repo "$SOURCE" HEAD "$SNAPSHOT" >"$FAKE_HOME/out" 2>&1
assert_file_not_exists "$SNAPSHOT/README.md"
assert_contains 'local addition' "$SNAPSHOT/local-note"
assert_dir_exists "$SNAPSHOT/.git"
[[ "$(git -C "$SNAPSHOT" rev-parse HEAD)" == "$(git -C "$SOURCE" rev-parse HEAD)" ]] \
  || fail '快照应保留 HEAD'
pass "无 rsync 的本地快照保留未提交删除和新增，并保留 Git 元数据"
