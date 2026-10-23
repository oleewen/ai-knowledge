#!/usr/bin/env bash
# test-core.sh — 测试兼容入口（供 agent/scripts/tests 与 skills/*/tests source）

if [[ -n "${_TEST_CORE_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _TEST_CORE_SH_LOADED=1

_TEST_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/path.sh
source "${_TEST_SCRIPTS_DIR}/lib/path.sh"
# shellcheck source=tests/lib/assertions.sh
source "${_TEST_SCRIPTS_DIR}/tests/lib/assertions.sh"
# shellcheck source=tests/lib/runner.sh
source "${_TEST_SCRIPTS_DIR}/tests/lib/runner.sh"
unset _TEST_SCRIPTS_DIR
