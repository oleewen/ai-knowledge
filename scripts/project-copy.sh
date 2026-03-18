#!/usr/bin/env bash
# project-copy.sh：将当前仓库根目录（排除 .git）拷贝到目标目录

set -euo pipefail

log() { printf '%s\n' "$*" >&2; }
error() { log "错误: $*"; exit 1; }

usage() {
  cat <<'EOF'
用法:
  ./scripts/project-copy.sh [--dry-run] <目标目录>

说明:
  将当前脚本所在仓库的根目录内容拷贝到目标目录，排除 .git/。

示例:
  ./scripts/project-copy.sh /path/to/your-project
  ./scripts/project-copy.sh --dry-run /path/to/your-project
EOF
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

abs_path() {
  # 将路径解析为绝对路径（不要求目标存在）
  local p="$1"
  if [[ "$p" != /* ]]; then
    p="$(pwd)/$p"
  fi
  printf '%s\n' "$p"
}

run() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[dry-run] $*"
    return 0
  fi
  "$@"
}

main() {
  DRY_RUN=0
  local target_input=""

  while (( $# > 0 )); do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      -h|--help) usage; exit 0 ;;
      --) shift; break ;;
      -*) error "未知选项: $1" ;;
      *) target_input="$1" ;;
    esac
    shift
  done

  if [[ -z "$target_input" ]]; then
    usage
    exit 2
  fi

  local script_dir repo_root src_root target_root
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  repo_root="$(cd "$script_dir/.." && pwd -P)"
  src_root="$repo_root"
  target_root="$(abs_path "$target_input")"

  if [[ ! -d "$src_root" ]]; then
    error "源目录不存在: $src_root"
  fi

  if [[ "$target_root" == "$src_root" ]]; then
    error "目标目录不能与源目录相同: $target_root"
  fi

  case "$target_root/" in
    "$src_root/"*)
      error "目标目录不能位于源目录内部（会导致递归拷贝）: $target_root"
      ;;
  esac

  log "信息: 源目录: $src_root"
  log "信息: 目标目录: $target_root"

  if [[ "$DRY_RUN" == "1" ]]; then
    if have_cmd rsync; then
      log "[dry-run] 将执行: rsync -a --exclude='.git/' \"$src_root/\" \"$target_root/\""
    else
      log "[dry-run] 将执行: mkdir -p \"$target_root\""
      log "[dry-run] 将执行: cp -R \"$src_root/.\" \"$target_root/\""
      log "[dry-run] 将执行: rm -rf \"$target_root/.git\""
    fi
    log "信息: dry-run 完成（未做任何变更）"
    return 0
  fi

  run mkdir -p "$target_root"

  if have_cmd rsync; then
    rsync -a --exclude='.git/' "$src_root"/ "$target_root"/
  else
    # cp 回退：先拷贝所有，再移除目标中的 .git（若存在）
    cp -R "$src_root"/. "$target_root"/
    rm -rf "$target_root/.git"
  fi

  log "信息: 拷贝完成"
}

main "$@"

