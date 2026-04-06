#!/usr/bin/env bash
# sdx-doc-root.sh — 文档树首段路径（doc_root segment）解析
# 单一事实来源：本文件；仓库根 scripts/sdx-doc-root.sh 为转发入口。
#
# 方案 A 顺序：
#   1) 显式传入 override（如 --doc-root）
#   2) 环境变量 SDX_DOC_ROOT
#   3) 工程根目录下文件 .sdx-doc-root（git 根优先，其次当前探测基目录）
#   4) 目录探测：优先 docs/*，其次 system/*、application/*（见 sdx_probe_doc_root_segment）
#   5) 无匹配目录时默认 docs
#
# Usage（由其它脚本 source）：
#   source ".../.ai/scripts/sdx-doc-root.sh"
#   seg="$(sdx_resolve_doc_root_segment "$CLI_OVERRIDE" "$PROBE_BASE")"
#
# PROBE_BASE 一般为仓库根（含 system/、docs/ 的目录）。

sdx_normalize_doc_root_segment() {
  local s="${1:-docs}"
  s="${s#/}"
  s="${s%/}"
  s="${s%%/*}"
  s="${s//[[:space:]]/}"
  [[ -n "$s" ]] || s="docs"
  printf '%s' "$s"
}

sdx_read_sdx_doc_root_file() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  local line
  IFS= read -r line < "$f" || true
  line="${line%%#*}"
  line="${line//$'\r'/}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -n "$line" ]] || return 1
  printf '%s' "$line"
}

# Usage: sdx_probe_doc_root_segment <probe_base>
sdx_probe_doc_root_segment() {
  local b="${1:-.}"
  if [[ "$b" != /* ]]; then
    b="$(cd "$b" 2>/dev/null && pwd || printf '%s' "$b")"
  else
    b="$(cd "$b" 2>/dev/null && pwd || printf '%s' "$b")"
  fi

  if [[ -d "$b/docs/knowledge" || -d "$b/docs/solutions" ]]; then
    printf 'docs'
    return
  fi
  if [[ -d "$b/docs/system/knowledge" ]]; then
    printf 'docs'
    return
  fi
  if [[ -d "$b/system/knowledge" || -d "$b/system/solutions" || -d "$b/system/analysis" ]]; then
    printf 'system'
    return
  fi
  if [[ -d "$b/application/knowledge" || -d "$b/application/solutions" ]]; then
    printf 'application'
    return
  fi
  printf 'docs'
}

# Usage: sdx_resolve_doc_root_segment [override] [probe_base]
sdx_resolve_doc_root_segment() {
  local override="${1:-}"
  local probe_base="${2:-}"

  if [[ -n "$override" ]]; then
    sdx_normalize_doc_root_segment "$override"
    return
  fi
  if [[ -n "${SDX_DOC_ROOT:-}" ]]; then
    sdx_normalize_doc_root_segment "${SDX_DOC_ROOT}"
    return
  fi

  if [[ -z "$probe_base" ]]; then
    probe_base="$(pwd)"
  fi
  probe_base="$(cd "$probe_base" 2>/dev/null && pwd || printf '%s' "$probe_base")"

  local git_root=""
  git_root="$(git -C "$probe_base" rev-parse --show-toplevel 2>/dev/null || true)"

  local f line
  for f in "${git_root:+$git_root/.sdx-doc-root}" "$probe_base/.sdx-doc-root"; do
    [[ -n "$f" && -f "$f" ]] || continue
    line="$(sdx_read_sdx_doc_root_file "$f")" || continue
    sdx_normalize_doc_root_segment "$line"
    return
  done

  sdx_probe_doc_root_segment "$probe_base"
}

# 自任意路径向上查找仓库根：存在 .ai/scripts/sdx-doc-root.sh（副本）或 scripts/sdx-doc-root.sh（转发）
# Usage: sdx_find_repo_root_from_path <start_dir>
sdx_find_repo_root_from_path() {
  local d="${1:-}"
  [[ -n "$d" ]] || return 1
  [[ -d "$d" ]] && d="$(cd "$d" && pwd)" || d="$(cd "$(dirname "$d")" && pwd)/$(basename "$d")"
  local _
  for _ in $(seq 1 16); do
    if [[ -f "$d/.ai/scripts/sdx-doc-root.sh" || -f "$d/scripts/sdx-doc-root.sh" ]]; then
      printf '%s' "$d"
      return 0
    fi
    [[ "$d" == "/" ]] && break
    d="$(dirname "$d")"
  done
  return 1
}
