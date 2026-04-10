#!/usr/bin/env bash
# 供 docs-init 集成测试 source；不单独执行。
set -euo pipefail

: "${DOCS_INIT_TEST_REPO_ROOT:?DOCS_INIT_TEST_REPO_ROOT 未设置}"

test_fail() {
  printf '[FAIL] %s\n' "$*" >&2
  exit 1
}

assert_eq() {
  local expected="$1" actual="$2" msg="${3:-}"
  if [[ "$expected" != "$actual" ]]; then
    test_fail "${msg:+$msg — }expected <$expected> actual <$actual>"
  fi
}

assert_file_exists() {
  local f="$1"
  [[ -f "$f" ]] || test_fail "文件不存在: $f"
}

assert_file_not_exists() {
  local f="$1"
  [[ ! -f "$f" ]] || test_fail "不应存在文件: $f"
}

assert_file_contains() {
  local f="$1" needle="$2"
  assert_file_exists "$f"
  grep -qF -- "$needle" "$f" || test_fail "文件中未找到片段: $needle （文件: $f）"
}

# 合并后的 stdout+stderr 中匹配子串
assert_output_contains() {
  local out="$1" needle="$2"
  printf '%s' "$out" | grep -qF -- "$needle" || test_fail "输出中未找到: $needle"
}

# Usage: run_expect_exit <expected_code> -- <command> [args...]
run_expect_exit() {
  local expected="$1"
  shift
  [[ "${1:-}" == "--" ]] || test_fail "run_expect_exit: 需要 -- 分隔符"
  shift
  set +e
  "$@"
  local code=$?
  set -e
  assert_eq "$expected" "$code" "命令退出码"
}

# 将本仓库复制到 $1；打印副本绝对路径（用于 REPO_ROOT= 副本）
docs_init_test_copy_repo() {
  local dest="$1"
  rm -rf "$dest"
  cp -a "${DOCS_INIT_TEST_REPO_ROOT}" "$dest"
  printf '%s' "$dest"
}

# 单文件校验和（无 openssl 时回退 wc -c）
docs_init_test_file_sha() {
  local f="$1"
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$f" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then sha256sum "$f" | awk '{print $1}'
  else wc -c <"$f"
  fi
}

count_files_under() {
  local d="$1"
  find "$d" -type f 2>/dev/null | wc -l | tr -d ' '
}

