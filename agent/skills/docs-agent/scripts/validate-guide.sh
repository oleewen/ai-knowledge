#!/usr/bin/env bash
# 校验根 README.md、AGENTS.md 与已落盘 INDEX-GUIDE.md。
set -euo pipefail

ROOT=""
STRICT=0
OUTPUT=both

usage() {
  cat <<'EOF'
用法:
  bash validate-guide.sh [--root PATH] [--output readme|agents|both] [--strict]

默认从当前 Git 仓库根或当前目录校验。未加 --strict 时，警告不使命令失败。
output 默认 both；单文件单元只检查所选文件，双文件完成后再检查重复度。
EOF
}

fail() {
  printf '[ERROR] %s\n' "$*"
  exit 2
}

while (($#)); do
  case "$1" in
    --root)
      [[ $# -ge 2 && -n "$2" ]] || fail '--root 缺少路径'
      ROOT="$2"
      shift 2
      ;;
    --strict)
      STRICT=1
      shift
      ;;
    --output)
      [[ $# -ge 2 ]] || fail '--output 缺少值'
      case "$2" in readme|agents|both) OUTPUT="$2";; *) fail '--output 须为 readme、agents 或 both';; esac
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "未知参数: $1"
      ;;
  esac
done

if [[ -z "$ROOT" ]]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
fi
ROOT="$(cd -P "$ROOT" 2>/dev/null && pwd -P)" || fail "无法进入根目录: $ROOT"

ERRORS=0
WARNINGS=0

log_error() {
  printf '[ERROR] %s\n' "$*"
  ((ERRORS += 1))
}

log_warn() {
  printf '[WARN]  %s\n' "$*"
  ((WARNINGS += 1))
}

log_ok() {
  printf '[OK]    %s\n' "$*"
}

read_doc_dir() {
  [[ -f "$ROOT/.docsconfig" ]] || return 0
  sed -n 's/^DOC_DIR[[:space:]]*=[[:space:]]*//p' "$ROOT/.docsconfig" | head -1
}

extract_links() {
  local file="$1" match raw link
  while IFS= read -r match; do
    raw="${match#*\(}"
    raw="${raw%\)}"
    if [[ "$raw" == "<"*">"* ]]; then
      link="${raw#<}"
      link="${link%%>*}"
    else
      link="${raw%%[[:space:]]*}"
    fi
    case "$link" in
      ''|https://*|http://*|ftp://*|mailto:*|\#*) continue ;;
    esac
    link="${link%%\#*}"
    link="${link%%\?*}"
    [[ -n "$link" ]] && printf '%s\n' "$link"
  done < <(grep -oE '\]\([^)]*\)' "$file" 2>/dev/null || true)
}

check_links() {
  local file="$1" label="$2" link resolved
  [[ -f "$file" ]] || return 0
  while IFS= read -r link; do
    [[ -n "$link" ]] || continue
    if [[ "$link" == /* ]]; then
      resolved="$ROOT$link"
    else
      resolved="$ROOT/$link"
    fi
    [[ -e "$resolved" || -L "$resolved" ]] || log_warn "$label 引用路径不存在: $link"
  done < <(extract_links "$file")
}

normalize_lines() {
  sed -E 's/^[[:space:]]+//; /^[[:space:]]*$/d' "$1" | LC_ALL=C sort -u
}

DOC_DIR="$(read_doc_dir || true)"
INDEX_PATH=""
candidates=("INDEX-GUIDE.md")
[[ -n "$DOC_DIR" ]] && candidates+=("$DOC_DIR/INDEX-GUIDE.md")
for candidate in "${candidates[@]}"; do
  if [[ -f "$ROOT/$candidate" ]]; then
    INDEX_PATH="$candidate"
    break
  fi
done

if [[ -n "$INDEX_PATH" ]]; then
  log_ok "INDEX-GUIDE 落盘路径: $INDEX_PATH"
else
  log_error "未找到 INDEX-GUIDE.md（已检查仓库根与 DOC_DIR）"
fi

README="$ROOT/README.md"
AGENTS="$ROOT/AGENTS.md"

if [[ "$OUTPUT" != agents && -f "$README" ]]; then
  log_ok "README.md 存在"
  check_links "$README" 'README.md'
elif [[ "$OUTPUT" != agents ]]; then
  log_error "README.md 不存在"
fi

if [[ "$OUTPUT" != readme && -f "$AGENTS" ]]; then
  log_ok "AGENTS.md 存在"
  check_links "$AGENTS" 'AGENTS.md'
  if [[ -n "$INDEX_PATH" ]]; then
    if grep -Fq "$INDEX_PATH" "$AGENTS"; then
      log_ok "AGENTS.md 引用了 INDEX-GUIDE: $INDEX_PATH"
    else
      log_warn "AGENTS.md 未引用当前 INDEX-GUIDE: $INDEX_PATH"
    fi
  fi
elif [[ "$OUTPUT" != readme ]]; then
  log_error "AGENTS.md 不存在"
fi

if [[ "$OUTPUT" == both && -f "$README" && -f "$AGENTS" ]]; then
  readme_lines="$(wc -l < "$README" | tr -d ' ')"
  agents_lines="$(wc -l < "$AGENTS" | tr -d ' ')"
  if (( readme_lines > 10 && agents_lines > 10 )); then
    dup_lines="$(comm -12 <(normalize_lines "$README") <(normalize_lines "$AGENTS") | wc -l | tr -d ' ')"
    min_lines=$((readme_lines < agents_lines ? readme_lines : agents_lines))
    threshold=$((min_lines / 4))
    (( threshold < 5 )) && threshold=5
    if (( dup_lines > threshold )); then
      log_warn "README 与 AGENTS 重复 ${dup_lines} 行，阈值 ${threshold}"
    else
      log_ok "README 与 AGENTS 重复度可接受（${dup_lines}/${threshold}）"
    fi
  fi
fi

printf '\n验证完成: %d 错误, %d 警告\n' "$ERRORS" "$WARNINGS"
if (( ERRORS > 0 || (STRICT && WARNINGS > 0) )); then
  exit 1
fi
