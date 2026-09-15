#!/usr/bin/env bash
# test-core.sh — 测试断言、用例收集与套件运行（供 agent/scripts/tests 与 skills/*/tests source）

if [[ -n "${_TEST_CORE_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _TEST_CORE_SH_LOADED=1

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

_TEST_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/path.sh
source "${_TEST_SCRIPTS_DIR}/lib/path.sh"
unset _TEST_SCRIPTS_DIR

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
  actual="$(path_canonical "$actual")"
  [[ "$actual" == "$resolved_expect" ]] \
    || test_fail "软链不匹配: $link -> $actual（期望 $resolved_expect）"
}

test_collect_case_scripts() {
  local case_dir="${1:?case_dir is required}"
  local -a cases=()

  [[ -d "$case_dir" ]] || test_fail "未找到测试目录: $case_dir"
  mapfile -t cases < <(find "$case_dir" -maxdepth 1 -type f -name '*.sh' | sort)
  ((${#cases[@]} > 0)) || test_fail "未发现测试用例: $case_dir"
  printf '%s\n' "${cases[@]}"
}

test_run_case_suite() {
  local title="${1:?title is required}"
  local runner_bin="${2:-${BASH:-bash}}"
  shift 2

  local -a cases=("$@")
  local total=0 passed=0 failed=0
  local case_file case_name

  printf '== %s ==\n' "$title"

  for case_file in "${cases[@]}"; do
    ((++total))
    case_name="$(basename "$case_file")"
    printf '\n[%d/%d] %s\n' "$total" "${#cases[@]}" "$case_name"
    if "$runner_bin" "$case_file"; then
      ((++passed))
    else
      ((++failed))
    fi
  done

  printf '\n== 测试结果 ==\n'
  printf '总计: %d, 通过: %d, 失败: %d\n' "$total" "$passed" "$failed"

  [[ "$failed" -eq 0 ]]
}
