#!/usr/bin/env bash
# federation-slot-symlink.sh — 联邦槽位软链与共用日志辅助（docs-link / docs-pull）
# 依赖：已 source docs-core.sh（abs_path / strip_trailing_slash）

if [[ -n "${_FEDERATION_SLOT_SYMLINK_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _FEDERATION_SLOT_SYMLINK_SH_LOADED=1

# 规范化 remote URL 便于比较（去尾部 .git、统一小写 scheme/host 不做过度猜测）
federation_normalize_git_url() {
  local u="${1:-}"
  u="${u%.git}"
  u="${u%/}"
  printf '%s' "$u"
}

# 解析槽位软链目标：有 .docsconfig 用 DOC_ROOT，否则 {path}/{doc_dir}
# Usage: federation_resolve_doc_root <repo_path> <doc_dir> → stdout abs path
federation_resolve_doc_root() {
  local repo_path="${1:?}" doc_dir="${2:-}"
  local cfg t_doc_root='' t_repo_root='' t_doc_dir='' t_agent_root='' t_agent_dirs='' t_ktype=''
  local saved_pwd fallback

  repo_path="$(strip_trailing_slash "$(abs_path "$repo_path")")"
  fallback=""
  if [[ -n "$doc_dir" ]]; then
    if [[ "$doc_dir" == /* ]]; then
      fallback="$(strip_trailing_slash "$(abs_path "$doc_dir")")"
    else
      fallback="$(strip_trailing_slash "$(abs_path "${repo_path}/${doc_dir}")")"
    fi
  fi

  cfg="${repo_path}/.docsconfig"
  if [[ -f "$cfg" ]]; then
    saved_pwd="$PWD"
    cd "$repo_path" || return 1
    if docsconfig_read_into "$cfg" t_doc_root t_repo_root t_doc_dir t_agent_root t_agent_dirs t_ktype; then
      cd "$saved_pwd" || true
      if [[ -n "$t_doc_root" ]]; then
        if [[ "$t_doc_root" == /* ]]; then
          printf '%s' "$(strip_trailing_slash "$(abs_path "$t_doc_root")")"
        else
          printf '%s' "$(strip_trailing_slash "$(abs_path "${repo_path}/${t_doc_root}")")"
        fi
        return 0
      fi
    else
      cd "$saved_pwd" || true
    fi
  fi

  [[ -n "$fallback" ]] || return 1
  printf '%s' "$fallback"
}

federation_ensure_shared_changelogs() {
  local slots_parent="${1:?}" # .../application-slots 或 .../system-slots
  local log_dir change_log archive_log
  log_dir="${slots_parent%/}/changelogs"
  change_log="${log_dir}/CHANGE-LOG.md"
  archive_log="${log_dir}/ARCHIVE-LOG.md"
  mkdir -p "$log_dir"
  if [[ ! -f "$change_log" ]]; then
    cat >"$change_log" <<'EOF'
---
type: Change Log
title: CHANGE-LOG（联邦槽位同步）
---
<!-- markdownlint-disable-next-line MD025 -->
# CHANGE-LOG（联邦槽位同步）

层内共用同步留痕。条目含 name / source / commit / action。

## 写入约定

- 新记录按时间倒序追加
- action：pull / clone / link-fix / migrate（可组合，如 migrate+pull）
EOF
  fi
  if [[ ! -f "$archive_log" ]]; then
    cat >"$archive_log" <<'EOF'
---
type: Change Log
title: ARCHIVE-LOG（联邦槽位蒸馏锚点）
---
<!-- markdownlint-disable-next-line MD025 -->
# ARCHIVE-LOG（联邦槽位蒸馏锚点）

层内共用蒸馏归档锚点。按应用/系统分节维护。
EOF
  fi
}

# 将旧槽位 changelogs 正文追加进共用日志（跳过 front matter 与首个 H1）
federation_merge_old_slot_changelog() {
  local old_file="${1:?}" shared_file="${2:?}" slot_name="${3:?}" kind="${4:-CHANGE-LOG}"
  local tmp body
  [[ -f "$old_file" ]] || return 0
  [[ -f "$shared_file" ]] || return 0
  tmp="$(mktemp)"
  {
    printf '\n\n## migrated_from: %s (%s)\n\n' "$slot_name" "$kind"
    # 去掉 YAML front matter
    awk '
      BEGIN { in_fm=0; fm_done=0; skip_h1=1 }
      /^---$/ && !fm_done { if (!in_fm) { in_fm=1; next } else { in_fm=0; fm_done=1; next } }
      in_fm { next }
      skip_h1 && /^# / { skip_h1=0; next }
      { print }
    ' "$old_file"
  } >>"$tmp"
  cat "$tmp" >>"$shared_file"
  rm -f "$tmp"
}

federation_migrate_real_slot_dir() {
  local slot_dir="${1:?}" shared_log_dir="${2:?}" slot_name="${3:?}"
  local old_change old_archive
  [[ -d "$slot_dir" && ! -L "$slot_dir" ]] || return 0
  old_change="${slot_dir%/}/changelogs/CHANGE-LOG.md"
  old_archive="${slot_dir%/}/changelogs/ARCHIVE-LOG.md"
  federation_merge_old_slot_changelog "$old_change" "${shared_log_dir%/}/CHANGE-LOG.md" "$slot_name" "CHANGE-LOG"
  federation_merge_old_slot_changelog "$old_archive" "${shared_log_dir%/}/ARCHIVE-LOG.md" "$slot_name" "ARCHIVE-LOG"
  rm -rf "$slot_dir"
}

# 确保 slot_dir 为指向 target_abs 的绝对路径软链；真目录则先迁移
# stdout: action 片段（空|migrate|link-fix）
federation_ensure_slot_symlink() {
  local slot_dir="${1:?}" target_abs="${2:?}" shared_log_dir="${3:?}" slot_name="${4:?}"
  local actions=() current parent
  target_abs="$(strip_trailing_slash "$(abs_path "$target_abs")")"
  parent="$(dirname "$slot_dir")"
  mkdir -p "$parent"
  federation_ensure_shared_changelogs "$(dirname "$slot_dir")"

  if [[ -d "$slot_dir" && ! -L "$slot_dir" ]]; then
    federation_migrate_real_slot_dir "$slot_dir" "$shared_log_dir" "$slot_name"
    actions+=("migrate")
  fi

  if [[ -L "$slot_dir" ]]; then
    current="$(readlink "$slot_dir" 2>/dev/null || true)"
    if [[ "$current" == "$target_abs" ]]; then
      if [[ ${#actions[@]} -gt 0 ]]; then
        local IFS='+'
        printf '%s' "${actions[*]}"
      fi
      return 0
    fi
    rm -f "$slot_dir"
    actions+=("link-fix")
  elif [[ -e "$slot_dir" ]]; then
    rm -rf "$slot_dir"
    actions+=("link-fix")
  fi

  ln -s "$target_abs" "$slot_dir"
  if [[ ${#actions[@]} -eq 0 ]]; then
    # 新建软链也记 link-fix，便于追溯
    actions+=("link-fix")
  fi
  local IFS='+'
  printf '%s' "${actions[*]}"
}

federation_remove_slot_path() {
  local slot_dir="${1:?}"
  if [[ -L "$slot_dir" ]]; then
    rm -f "$slot_dir"
    return 0
  fi
  if [[ -d "$slot_dir" ]]; then
    rm -rf "$slot_dir"
  fi
}

federation_append_pull_change_log() {
  local shared_change_log="${1:?}" slot_key="${2:?}" slot_name="${3:?}" source_repo="${4:?}" commit="${5:?}" action="${6:?}"
  local synced_at
  [[ -f "$shared_change_log" ]] || return 1
  synced_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  {
    printf '\n'
    printf '## synced_at: %s\n' "$synced_at"
    printf '\n'
    printf -- '- %s: %s\n' "$slot_key" "$slot_name"
    printf -- '- source: %s\n' "$source_repo"
    printf -- '- commit: %s\n' "$commit"
    printf -- '- action: %s\n' "$action"
  } >>"$shared_change_log"
}

federation_git_origin_url() {
  local repo="${1:?}"
  git -C "$repo" remote get-url origin 2>/dev/null || true
}

federation_git_is_dirty() {
  local repo="${1:?}"
  [[ -n "$(git -C "$repo" status --porcelain 2>/dev/null || true)" ]]
}
