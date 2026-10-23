#!/usr/bin/env bash
# lib/docsconfig-store.sh — 配置、工作区持久化与 Agent 字段补齐
# 由 docsconfig.sh 加载；不设独立哨兵，随聚合入口换根刷新。

# Usage: docsconfig_write <repo_root> <doc_root> <doc_dir> [dry] [agent_root] [knowledge_type] [agent_dir]
docsconfig_write() {
  local repo_root="${1:?repo_root}"
  local doc_root="${2:?doc_root}"
  local doc_dir="${3:?doc_dir}"
  local dry="${4:-0}"
  local agent_root_in="${5:-}"
  local knowledge_type_in="${6:-}"
  local agent_dir_in="${7:-}"

  # 兼容旧调用：第 5 位误传 knowledge_type、未传 agent_root
  if [[ -n "$agent_root_in" && -z "$knowledge_type_in" ]]; then
    case "$agent_root_in" in
      application|system|solution|company|meta)
        knowledge_type_in="$agent_root_in"
        agent_root_in=''
        ;;
    esac
  fi

  local out repo_dir computed_dd
  out="$(strip_trailing_slash "$(abs_path "$repo_root")")/.docsconfig"
  repo_dir="$(basename "$(strip_trailing_slash "$(abs_path "$repo_root")")")"
  docsconfig_validate_repo_dir "$repo_dir" || return 1
  docsconfig_validate_doc_dir "$doc_dir" || return 1
  computed_dd="$(docsconfig_doc_dir_from_roots "$repo_root" "$doc_root")" || return 1
  if [[ "$computed_dd" != "$doc_dir" ]]; then
    _docsconfig_err "[docsconfig] DOC_DIR 与文档路径不一致: ${doc_dir} vs ${computed_dd}"
    return 1
  fi

  if [[ -n "$knowledge_type_in" ]]; then
    docsconfig_validate_knowledge_type "$knowledge_type_in" || return 1
  fi

  if [[ -n "$agent_root_in" ]] && declare -F docsconfig_agent_root_looks_like_entity_tree >/dev/null 2>&1; then
    if docsconfig_agent_root_looks_like_entity_tree "$agent_root_in"; then
      _docsconfig_err "[docsconfig] AGENT_ROOT 不能指向实体树（当前像是 ${agent_root_in}）。请改为家目录（如 ~）并设置 AGENT_DIR=.agents（或探测到的 IDE 根名）。"
      return 1
    fi
  fi

  if [[ -n "$agent_root_in" && -z "$agent_dir_in" ]]; then
    _docsconfig_err "[docsconfig] 已设 AGENT_ROOT 但缺少 AGENT_DIR。请在 .docsconfig 补充 AGENT_DIR=.agents（或探测到的目录名）。"
    return 1
  fi

  if [[ "$dry" == '1' ]]; then
    printf 'Would write %s:\n' "$out"
    docsconfig_print_kv_block "$repo_dir" "$doc_dir" "$knowledge_type_in" "$agent_root_in" "$agent_dir_in"
    return 0
  fi

  umask 022
  {
    docsconfig_print_kv_block "$repo_dir" "$doc_dir" "$knowledge_type_in" "$agent_root_in" "$agent_dir_in"
  } >"$out"
}

docsconfig_write_workspace() {
  local store="${1:?}" workspace="${2:?}" dry="${3:-0}"
  local formatted path
  formatted="$(docsconfig_format_root_for_write "$workspace")"
  path="$(strip_trailing_slash "$(abs_path "$store")")/configs"
  if [[ "$dry" == '1' ]]; then
    printf 'Would write %s:\nWORK_SPACE=%s\n' "$path" "$formatted"
    return 0
  fi
  umask 022
  printf 'WORK_SPACE=%s\n' "$formatted" >"$path"
}

# 补齐 AGENT_ROOT/AGENT_DIR：已齐且可解析则保留；否则探测写入输出变量。
# 用法：docsconfig_fill_agent_fields <out_root> <out_dir> <old_root> <old_dir> [home]
docsconfig_fill_agent_fields() {
  local ar_out ad_out
  local old_ar="${3:-}"
  local old_ad="${4:-}"
  local home="${5:-${HOME:-}}"
  local tree=''

  ar_out=''
  ad_out=''

  if [[ -n "$old_ar" ]]; then
    if declare -F docsconfig_agent_root_looks_like_entity_tree >/dev/null 2>&1 \
      && docsconfig_agent_root_looks_like_entity_tree "$old_ar"; then
      _docsconfig_err "[docsconfig] 已有 AGENT_ROOT 指向实体树（${old_ar}）。请手改为家目录（如 ~）并设置 AGENT_DIR 后再跑。"
      return 1
    fi
  fi

  if [[ -n "$old_ar" && -n "$old_ad" ]]; then
    tree="$(strip_trailing_slash "$(abs_path "${old_ar}/${old_ad}")")"
    if declare -F agent_layout_is_install_root >/dev/null 2>&1 && agent_layout_is_install_root "$tree"; then
      ar_out="$(strip_trailing_slash "$(abs_path "$old_ar")")"
      ad_out="$old_ad"
      eval "${1:?}=\$ar_out"
      eval "${2:?}=\$ad_out"
      return 0
    fi
    _docsconfig_info "已有 AGENT_ROOT/AGENT_DIR 无法解析为安装树，将重新探测…"
  fi

  if ! declare -F probe_agent_install_root >/dev/null 2>&1; then
    # shellcheck source=agent-layout.sh
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/agent-layout.sh"
  fi
  probe_agent_install_root ar_out ad_out "$home" || return 1
  eval "${1:?}=\$ar_out"
  eval "${2:?}=\$ad_out"
  _docsconfig_info "已探测 Agent 安装根: AGENT_ROOT=${ar_out} AGENT_DIR=${ad_out}"
}
