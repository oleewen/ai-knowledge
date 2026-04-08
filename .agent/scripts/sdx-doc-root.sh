#!/usr/bin/env bash
# sdx-doc-root.sh — 文档树首段路径（doc_root segment）解析
# 单一事实来源：本文件（路径 `.agent/scripts/sdx-doc-root.sh`）。
#
# 推断顺序：
#   1) 显式传入 override（如 --doc-root）
#   2) 环境变量 REPO_DOC_ROOT
#   3) 工程根目录下文件 .sdx-doc-root（git 根优先，其次当前探测基目录）
#   4) 目录探测：优先 `docs/`，其次应用知识库 `application/knowledge/*`，再者系统知识库 `system/knowledge/*`，然后公司知识库 `company/knowledge/*`，最后探测知识库 `*/knowledge/*`（见 sdx_probe_doc_root_segment）
#   5) 无匹配目录时默认 docs
#
# Usage（由其它脚本 source）：
#   source ".../.agent/scripts/sdx-doc-root.sh"
#   REPO_DOC_ROOT="$(sdx_resolve_repo_doc_root "$CLI_OVERRIDE" "$PROBE_BASE")"   # 文档树根目录绝对路径
#
# PROBE_BASE 一般为仓库根（含 application/、docs/ 的目录）。
# 对外仅导出 sdx_resolve_repo_doc_root；首段名解析为内部实现（_sdx_doc_root_segment）。

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
  if [[ -d "$b/docs/application/knowledge" ]]; then
    printf 'docs'
    return
  fi
  # 中央库新布局：application/ 为应用知识库 SSOT
  if [[ -d "$b/application/knowledge" || -d "$b/application/solutions" || -d "$b/application/analysis" ]]; then
    printf 'application'
    return
  fi
  # 旧工程：顶层仍为 system/ 知识树（迁移前中央库布局；与新建语义化 system/ 壳目录无 knowledge/ 不冲突）
  if [[ -d "$b/system/knowledge" || -d "$b/system/solutions" || -d "$b/system/analysis" ]]; then
    printf 'system'
    return
  fi
  # 公司知识库
  if [[ -d "$b/company/knowledge" || -d "$b/company/solutions" || -d "$b/company/analysis" ]]; then
    printf 'company'
    return
  fi
  # 其余任意顶层目录下的 knowledge/（前述均未命中时）
  local _top
  shopt -s nullglob
  for _top in "$b"/*/; do
    [[ -d "${_top}knowledge" ]] || continue
    printf '%s' "$(basename "${_top%/}")"
    shopt -u nullglob
    return
  done
  shopt -u nullglob
  printf 'docs'
}

# 内部：解析文档树首段名（不单独对外导出）。
# Usage: _sdx_doc_root_segment [override] [probe_base]
_sdx_doc_root_segment() {
  local override="${1:-}"
  local probe_base="${2:-}"

  if [[ -n "$override" ]]; then
    sdx_normalize_doc_root_segment "$override"
    return
  fi
  if [[ -n "${REPO_DOC_ROOT:-}" ]]; then
    local seg="${REPO_DOC_ROOT%/}"
    seg="${seg##*/}"
    sdx_normalize_doc_root_segment "$seg"
    return
  fi
  # 兼容历史环境变量：SDX_DOC_ROOT（仅首段名）
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

# Usage: sdx_resolve_repo_doc_root [override] [probe_base]
# 输出：文档树根目录的绝对路径（规范化后的 probe_base + / + 首段）。
# 供各 validate-*.sh 设置 REPO_DOC_ROOT。
sdx_resolve_repo_doc_root() {
  local override="${1:-}"
  local probe_base="${2:-}"
  local seg base
  seg="$(_sdx_doc_root_segment "$override" "$probe_base")"
  if [[ -z "$probe_base" ]]; then
    probe_base="$(pwd)"
  fi
  base="$(cd "$probe_base" 2>/dev/null && pwd || printf '%s' "$probe_base")"
  printf '%s/%s' "$base" "$seg"
}

# 自任意路径向上查找仓库根：存在 .agent/scripts/sdx-doc-root.sh
# Usage: sdx_find_repo_root_from_path <start_dir>
sdx_find_repo_root_from_path() {
  local d="${1:-}"
  [[ -n "$d" ]] || return 1
  [[ -d "$d" ]] && d="$(cd "$d" && pwd)" || d="$(cd "$(dirname "$d")" && pwd)/$(basename "$d")"
  local _
  for _ in $(seq 1 16); do
    if [[ -f "$d/.agent/scripts/sdx-doc-root.sh" ]]; then
      printf '%s' "$d"
      return 0
    fi
    [[ "$d" == "/" ]] && break
    d="$(dirname "$d")"
  done
  return 1
}
