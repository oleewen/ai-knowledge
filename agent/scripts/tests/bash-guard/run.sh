#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_ROOT="$(cd "$TEST_ROOT/../../../.." && pwd)"
source "$META_ROOT/agent/scripts/test-core.sh"

printf '== Bash 5+ 守卫 ==\n'

assert_file_exists "$META_ROOT/agent/scripts/lib/bash.sh"
assert_contains 'require_bash5' "$META_ROOT/agent/scripts/lib/bash.sh"

while IFS= read -r file; do
  [[ -f "$file" ]] || continue
  if [[ "$(head -n 1 "$file")" == '#!/bin/bash' ]]; then
    test_fail "禁止硬编码系统 Bash shebang: $file"
  fi
done < <(git -C "$META_ROOT" ls-files '*.sh' '*.bash')

for file in \
  agent/scripts/lib/agents.sh \
  agent/scripts/lib/knowledge-links.sh \
  agent/scripts/lib/path.sh \
  agent/scripts/lib/slot-softlink.sh \
  agent/skills/agent-install/scripts/agent-config.sh \
  agent/skills/agent-install/scripts/agent-install.sh \
  agent/skills/docs-install/scripts/docs-config.sh \
  agent/skills/docs-install/scripts/docs-install.sh \
  agent/skills/docs-pull/scripts/pull-slots.sh \
  agent/skills/sdx-solution/scripts/validate-solution.sh; do
  assert_contains 'bash.sh' "$META_ROOT/$file"
done

# docs-upgrade 通过共享入口加载守卫，无须重复直接 source bash.sh。
upgrade="$META_ROOT/agent/skills/docs-upgrade/scripts/docs-upgrade.sh"
assert_contains 'docs-core.sh' "$upgrade"
assert_contains 'bash.sh' "$META_ROOT/agent/scripts/docs-core.sh"
if [[ -x /bin/bash ]] && (( $(/bin/bash -c 'printf "%s" "${BASH_VERSINFO[0]}"') < 5 )); then
  if guard_output="$(/bin/bash "$upgrade" --help 2>&1)"; then
    test_fail 'docs-upgrade 未拒绝 Bash 5 以下版本'
  fi
  [[ "$guard_output" == *'需要 Bash 5+'* ]] || test_fail "docs-upgrade 未通过版本守卫停止: $guard_output"
else
  printf '[SKIP] 无 /bin/bash 旧版本；已检查共享守卫加载链\n'
fi

printf '[OK] Bash 5+ 守卫检查通过\n'
