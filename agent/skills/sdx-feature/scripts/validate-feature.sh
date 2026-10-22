#!/usr/bin/env bash
set -euo pipefail

# FEATURE 结构校验入口；只读，不承担业务语义或用户确认门禁。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck source=../../../scripts/lib/bash.sh
source "$_AGENT_HOME/scripts/lib/bash.sh"

usage() {
  cat <<'USAGE'
用法: validate-feature.sh [--file <path>] [--strict]

  --file <path>  只检查指定文件；相对路径按当前目录解析，无需 .docsconfig
  --strict       内容警告也返回非零；默认仅读取/格式错误返回非零
  -h, --help     显示帮助

未指定 --file 时，从当前目录向上读取 .docsconfig，扫描 DOC_DIR/features/。
依赖 Bash 5+、Python 3 标准库。仅校验结构与可机械检查内容，不检查业务语义或用户确认。
USAGE
}

fail_usage() {
  printf '[ERROR] %s\n' "$1" >&2
  usage >&2
  exit 2
}

TARGET_FILE=''
STRICT=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || fail_usage '缺少 --file 路径'
      [[ -z "$TARGET_FILE" ]] || fail_usage '--file 不可重复'
      TARGET_FILE="$2"
      shift 2
      ;;
    --file=*)
      [[ -z "$TARGET_FILE" ]] || fail_usage '--file 不可重复'
      TARGET_FILE="${1#*=}"
      [[ -n "$TARGET_FILE" ]] || fail_usage '缺少 --file 路径'
      shift
      ;;
    --strict) STRICT=(--strict); shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail_usage "未知参数: $1" ;;
  esac
done

command -v python3 >/dev/null 2>&1 || {
  printf '[ERROR] 未找到 python3，无法执行 FEATURE 结构校验。\n' >&2
  exit 1
}

if [[ -n "$TARGET_FILE" ]]; then
  exec python3 -B "$SCRIPT_DIR/validate_feature.py" "${STRICT[@]}" --file "$TARGET_FILE"
fi

# shellcheck source=../../../scripts/lib/docsconfig.sh
source "$_AGENT_HOME/scripts/lib/docsconfig.sh"
docsconfig_bootstrap_validate
exec python3 -B "$SCRIPT_DIR/validate_feature.py" "${STRICT[@]}" --scan "$(docsconfig_doc_abs)/features"
