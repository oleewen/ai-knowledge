#!/usr/bin/env bash
# 用例收集与套件执行；由 test-core.sh 加载。

test_collect_case_scripts() {
  local case_dir="${1:?case_dir is required}"
  local -a cases=()

  [[ -d "$case_dir" ]] || test_fail "未找到测试目录: $case_dir"
  local file
  while IFS= read -r file; do
    cases+=("$file")
  done < <(find "$case_dir" -maxdepth 1 -type f -name '*.sh' | sort)
  ((${#cases[@]} > 0)) || test_fail "未发现测试用例: $case_dir"
  printf '%s\n' "${cases[@]}"
}

test_bash5_command() {
  local candidate
  for candidate in "${BASH:-}" /opt/homebrew/bin/bash /usr/local/bin/bash bash; do
    [[ -n "$candidate" ]] || continue
    candidate="$(command -v "$candidate" 2>/dev/null)" || continue
    [[ -x "$candidate" ]] || continue
    "$candidate" -c '((BASH_VERSINFO[0] >= 5))' >/dev/null 2>&1 || continue
    printf '%s\n' "$candidate"
    return 0
  done
  return 1
}

test_run_case_suite() {
  local title="${1:?title is required}"
  local runner_bin="${2:-}"
  shift
  if (($# > 0)); then
    shift
  fi

  local -a cases=("$@")
  ((${#cases[@]} > 0)) || test_fail "未提供测试用例: $title"
  if [[ -z "$runner_bin" ]]; then
    runner_bin="$(test_bash5_command)" || test_fail "未找到 Bash 5+ 运行器"
  fi
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
