#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
source "$SCRIPTS_ROOT/lib/git-remote.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/tools" "$TMP_DIR/plain/.git"
for tool in sed head awk; do ln -s "$(command -v "$tool")" "$TMP_DIR/tools/$tool"; done
fallback_remote() ( PATH="$TMP_DIR/tools"; git_remote_url_prefer_origin "$1"; )
cat >"$TMP_DIR/plain/.git/config" <<'CONFIG'
[remote "upstream"]
  url = https://example.test/first.git
[remote "origin"]
  url = https://example.test/origin.git
[remote "later"]
  url = https://example.test/later.git
CONFIG
actual="$(fallback_remote "$TMP_DIR/plain")"
[[ "$actual" == https://example.test/origin.git ]] || fail 'fallback origin 必须优先且只输出一个 URL'
cat >"$TMP_DIR/plain/.git/config" <<'CONFIG'
[remote "upstream"]
  url = https://example.test/first.git
[remote "later"]
  url = https://example.test/later.git
CONFIG
[[ "$(fallback_remote "$TMP_DIR/plain")" == https://example.test/first.git ]] || fail '无 origin 时只输出首个 remote'
mkdir -p "$TMP_DIR/relative/.control/worktrees/topic"
printf 'gitdir: .control/worktrees/topic\n' >"$TMP_DIR/relative/.git"
printf '../..\n' >"$TMP_DIR/relative/.control/worktrees/topic/commondir"
printf '[remote "origin"]\n  url = https://example.test/relative.git\n' >"$TMP_DIR/relative/.control/config"
[[ "$(fallback_remote "$TMP_DIR/relative")" == https://example.test/relative.git ]] || fail '应解析相对 gitdir 和 commondir'
mkdir -p "$TMP_DIR/absolute" "$TMP_DIR/control/worktrees/topic" "$TMP_DIR/common"
printf 'gitdir: %s\n' "$TMP_DIR/control/worktrees/topic" >"$TMP_DIR/absolute/.git"
printf '%s\n' "$TMP_DIR/common" >"$TMP_DIR/control/worktrees/topic/commondir"
printf '[remote "origin"]\n  url = https://example.test/absolute.git\n' >"$TMP_DIR/common/config"
[[ "$(fallback_remote "$TMP_DIR/absolute")" == https://example.test/absolute.git ]] || fail '应解析绝对 gitdir 和 commondir'
mkdir -p "$TMP_DIR/pointer/git-storage"
printf 'gitdir: git-storage\n' >"$TMP_DIR/pointer/.git"
printf '[remote "origin"]\n  url = https://example.test/pointer.git\n' >"$TMP_DIR/pointer/git-storage/config"
[[ "$(fallback_remote "$TMP_DIR/pointer")" == https://example.test/pointer.git ]] || fail '.git 指针无 commondir 时读取自身 config'
for repo in "$TMP_DIR/empty" "$TMP_DIR/plain"; do
  mkdir -p "$repo/.git"
  printf '[core]\n  bare = false\n' >"$repo/.git/config"
  rc=0
  fallback_remote "$repo" >"$TMP_DIR/no-remote" || rc=$?
  [[ "$rc" == 1 && ! -s "$TMP_DIR/no-remote" ]] || fail '缺 remote 必须返回 1 且无输出'
done
# CLI 路径同样优先 origin；所有 Git 写操作仅在临时仓。
git -C "$TMP_DIR/plain" init -q
git -C "$TMP_DIR/plain" remote add upstream https://example.test/upstream.git
git -C "$TMP_DIR/plain" remote add origin https://example.test/cli.git
[[ "$(git_remote_url_prefer_origin "$TMP_DIR/plain")" == https://example.test/cli.git ]] || fail 'CLI origin 优先契约漂移'
pass '无 Git fallback 单一 URL、origin 优先、gitdir/commondir、无远端状态'
