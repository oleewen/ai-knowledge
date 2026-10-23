#!/usr/bin/env bash
# 测试专属断言；由 test-core.sh 加载。

test_fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

test_pass() {
  printf 'PASS: %s\n' "$*"
}

# 兼容旧用例短名
fail() { test_fail "$@"; }
pass() { test_pass "$@"; }

_test_rg_fixed() {
  local needle="${1:?}" path="${2:?}"
  rg --fixed-strings --quiet "$needle" "$path"
}

assert_file_exists() {
  local path="${1:?path is required}"
  [[ -f "$path" ]] || test_fail "文件不存在: $path"
}

assert_file_not_exists() {
  local path="${1:?path is required}"
  [[ ! -f "$path" ]] || test_fail "文件不应存在: $path"
}

assert_dir_exists() {
  local path="${1:?path is required}"
  [[ -d "$path" ]] || test_fail "目录不存在: $path"
}

assert_dir_not_exists() {
  local path="${1:?path is required}"
  [[ ! -e "$path" ]] || test_fail "路径不应存在: $path"
}

assert_contains() {
  local needle="${1:?needle is required}"
  local path="${2:?path is required}"
  _test_rg_fixed "$needle" "$path" \
    || test_fail "未命中内容: $needle ($path)"
}

assert_not_contains() {
  local needle="${1:?needle is required}"
  local path="${2:?path is required}"
  if _test_rg_fixed "$needle" "$path" 2>/dev/null; then
    test_fail "命中不应出现内容: $needle ($path)"
  fi
}

assert_symlink_points_to() {
  local link="${1:?link is required}"
  local expect="${2:?expect is required}"
  local actual resolved_expect

  [[ -L "$link" ]] || test_fail "不是软链: $link"
  actual="$(readlink "$link" 2>/dev/null || true)"
  [[ -n "$actual" ]] || test_fail "readlink 失败: $link"

  # 规范化比对（与生产侧 symlink_points_to 的精确字符串比对不同：测试容忍相对/绝对等价）
  resolved_expect="$(path_canonical "$expect")"
  [[ "$actual" == /* ]] || actual="$(dirname "$link")/$actual"
  actual="$(path_canonical "$actual")"
  [[ "$actual" == "$resolved_expect" ]] \
    || test_fail "软链不匹配: $link -> ${actual}（期望 ${resolved_expect}）"
}
