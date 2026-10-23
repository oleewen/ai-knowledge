#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
# 不能在父进程比较 command substitution 的 errexit；在干净子 shell 用 $- 与 SHELLOPTS 保存选项。
for options in '' '-e' '-u' '-o pipefail' '-eu -o pipefail'; do
  "$BASH" -c '
    set +e +u +o pipefail
    case "$2" in
      "") ;;
      -e) set -e ;;
      -u) set -u ;;
      "-o pipefail") set -o pipefail ;;
      "-eu -o pipefail") set -eu -o pipefail ;;
    esac
    before_flags=$- before_options=$SHELLOPTS
    source "$1"
    [[ "$-" == "$before_flags" && "$SHELLOPTS" == "$before_options" ]] || {
      printf "FAIL: source version 修改 shell 选项，初始 %s\\n" "$2" >&2; exit 1;
    }
    [[ "$(version_normalize 2026.1020.08)" == 2026.1020.8 ]]
  ' version-source "$SCRIPTS_ROOT/lib/version.sh" "$options" || fail "version source 选项回归失败: $options"
done
pass 'version source 保留全部调用方 shell 选项'
