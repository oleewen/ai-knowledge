#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/test-core.sh"

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/links" "$fixture/targets" "$fixture/elsewhere/deep"
printf 'target\n' >"$fixture/targets/item"
ln -s ../targets/item "$fixture/links/relative"
ln -s "$fixture/targets/item" "$fixture/links/absolute"
ln -s ../targets/missing "$fixture/links/dangling"

cd "$fixture/elsewhere/deep"
assert_symlink_points_to "$fixture/links/relative" "$fixture/targets/item"
assert_symlink_points_to ../../links/relative ../../targets/item
assert_symlink_points_to "$fixture/links/absolute" "$fixture/targets/item"
assert_symlink_points_to "$fixture/links/dangling" "$fixture/targets/missing"
if (assert_symlink_points_to "$fixture/links/relative" "$fixture/targets/other") 2>/dev/null; then
  fail '软链断言接受了错误目标'
fi
pass '相对软链以链接父目录解析，绝对及失效软链保持可比对'
