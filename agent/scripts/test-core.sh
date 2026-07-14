#!/usr/bin/env bash

if [[ -n "${_SDX_TEST_CORE_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _SDX_TEST_CORE_SH_LOADED=1

test_fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

test_pass() {
  printf 'PASS: %s\n' "$*"
}

fail() {
  test_fail "$@"
}

pass() {
  test_pass "$@"
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
  [[ ! -e "$path" ]] || test_fail "path should not exist: $path"
}

assert_contains() {
  local needle="${1:?needle is required}"
  local path="${2:?path is required}"
  rg --fixed-strings "$needle" "$path" >/dev/null \
    || test_fail "未命中内容: $needle ($path)"
}

assert_not_contains() {
  local needle="${1:?needle is required}"
  local path="${2:?path is required}"
  if rg --fixed-strings "$needle" "$path" >/dev/null 2>&1; then
    test_fail "命中不应出现内容: $needle ($path)"
  fi
}

assert_symlink_points_to() {
  local link="${1:?link is required}"
  local expect="${2:?expect is required}"
  [[ -L "$link" ]] || test_fail "not a symlink: $link"

  local actual
  local resolved_expect
  actual="$(readlink "$link" 2>/dev/null || true)"
  [[ -n "$actual" ]] || test_fail "readlink failed: $link"
  resolved_expect="$(cd "$(dirname "$expect")" 2>/dev/null && pwd -P)/$(basename "$expect")"
  actual="$(cd "$(dirname "$actual")" 2>/dev/null && pwd -P)/$(basename "$actual")"
  [[ "$actual" == "$resolved_expect" ]] || test_fail "symlink mismatch: $link -> $actual (expected $resolved_expect)"
}

test_collect_case_scripts() {
  local case_dir="${1:?case_dir is required}"
  [[ -d "$case_dir" ]] || test_fail "未找到测试目录: $case_dir"

  local -a cases=()
  while IFS= read -r case_file; do
    [[ -n "$case_file" ]] && cases+=("$case_file")
  done < <(find "$case_dir" -maxdepth 1 -type f -name '*.sh' | sort)

  ((${#cases[@]} > 0)) || test_fail "未发现测试用例: $case_dir"
  printf '%s\n' "${cases[@]}"
}

test_run_case_suite() {
  local title="${1:?title is required}"
  local runner_bin="${2:-${BASH:-bash}}"
  shift 2

  local -a cases=( "$@" )
  local total=0
  local passed=0
  local failed=0
  local case_file
  local case_name

  printf '== %s ==\n' "$title"

  for case_file in "${cases[@]}"; do
    total=$((total + 1))
    case_name="$(basename "$case_file")"
    printf '\n[%d/%d] %s\n' "$total" "${#cases[@]}" "$case_name"
    if "$runner_bin" "$case_file"; then
      passed=$((passed + 1))
    else
      failed=$((failed + 1))
    fi
  done

  printf '\n== 测试结果 ==\n'
  printf '总计: %d, 通过: %d, 失败: %d\n' "$total" "$passed" "$failed"

  [[ "$failed" -eq 0 ]]
}
