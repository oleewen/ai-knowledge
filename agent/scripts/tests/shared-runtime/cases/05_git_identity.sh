#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
source "$SCRIPTS_ROOT/lib/slot-softlink.sh"
declare -f git_remote_identity_key >/dev/null || fail '缺少共享 Git remote 身份函数'
for value in 'https://Host/repo.git' 'https://Host/repo' 'HTTPS://Host/repo.git/' 'git@Host:Repo.git' 'https://Host/repo.git//' ''; do
  expect="${value%/}"
  [[ "$(git_remote_identity_key "$value")" == "$expect" ]] || fail "身份函数只可移除单个末尾 /: $value"
  [[ "$(slot_normalize_git_url "$value")" == "$expect" ]] || fail "slot wrapper 必须使用同一身份规则: $value"
done
[[ "$(git_remote_identity_key https://Host/repo.git)" != "$(git_remote_identity_key https://Host/repo)" ]] || fail '不得扩大 .git 身份等价'
[[ "$(git_remote_identity_key https://Host/repo)" != "$(git_remote_identity_key https://host/repo)" ]] || fail '不得扩大大小写等价'
[[ "$(git_remote_identity_key git@Host:Repo.git)" != "$(git_remote_identity_key https://Host/Repo.git)" ]] || fail '不得扩大协议等价'
pass 'Git 身份仅移除单个末尾 /，slot 复用且保留 .git/大小写/协议差异'
