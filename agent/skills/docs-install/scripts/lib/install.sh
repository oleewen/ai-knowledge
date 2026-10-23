#!/usr/bin/env bash
# docs-install 私有写入阶段：预检通过后才调用。

# 备份采用共享 helper；失败时主入口报告同一目录。
backup_path() {
  docs_backup_path_to_init "${CFG[target_dir]}" "$1" "$DOC_INIT_STAMP" "${CFG[dry_run]}"
}

get_backup_root() { printf '%s/.docs-init/%s' "${CFG[target_dir]}" "$DOC_INIT_STAMP"; }

# 备份并清空 DOC_DIR（保留目录本身）
reset_docs_dir_with_backup() {
  local docs_dir="${CFG[docs_abs]}"
  [[ -n "$docs_dir" && "$docs_dir" != '/' ]] || error "拒绝清空非法 DOC_DIR: ${docs_dir:-<empty>}"

  if [[ ! -d "$docs_dir" ]]; then
    info "DOC_DIR 不存在，创建空目录后继续: $docs_dir"
    ensure_dir "$docs_dir"
    return 0
  fi

  local -a entries=()
  local p
  while IFS= read -r -d '' p; do
    entries+=("$p")
  done < <(find "$docs_dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null || true)

  if (( ${#entries[@]} == 0 )); then
    info "DOC_DIR 已为空，无需清理: $docs_dir"
    return 0
  fi

  info ">>> 知识库同步前备份并清空 DOC_DIR: $docs_dir"

  if [[ "${CFG[dry_run]}" == '1' ]]; then
    local e
    for e in "${entries[@]}"; do
      log "[dry-run] 备份并移出: $e → $(get_backup_root)/..."
    done
    return 0
  fi

  local e
  for e in "${entries[@]}"; do
    backup_path "$e"
  done
  ensure_dir "$docs_dir"
  info "DOC_DIR 已清空（目录保留）: $docs_dir"
}

# 知识库安装并写入 .docsconfig 后：建 .agents 软链（非 meta）并按模式重写路径
# 实现见 lib/rewrite.sh、lib/agent-layout.sh
docs_install_rewrite_agent_paths() {
  [[ "${CFG[dry_run]}" == 0 ]] || return 0
  local rd='' dd='' agent_root='' knowledge_type='' agent_dir='' mode=consumer
  docsconfig_read_into "${CFG[config_file]}" rd dd agent_root knowledge_type agent_dir
  [[ "$knowledge_type" != meta ]] || mode=meta
  if [[ "$mode" == consumer ]]; then
    ensure_docs_agents_symlink "${CFG[docs_abs]}" "$agent_root" "$agent_dir" 0
  fi
  rewrite_docs_agent_paths "${CFG[docs_abs]}" "$mode"
}

# 步骤 1a：application/ 全量 → 目标（standalone 或默认）
install_application_full_to_docs() {
  local src_root="${CFG[source_dir]}"
  local dst_root="${CFG[docs_abs]}"

  [[ -d "$src_root" ]] || error "未找到 application 目录: $src_root"
  info ">>> 初始化 application/（全量）→ 目标文档目录"
  info "    源:   $src_root"
  info "    目标: $dst_root"

  local rel src_f dst_f
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    # 仅排除 application/ 根部多版本 README（子目录 README.md 须照常同步）
    # 根级 DESIGN.md 随源树整文件覆盖同步（DESIGN = 层设计入口模板）
    [[ "$rel" == 'README.md' || "$rel" == 'README-s.md' || "$rel" == 'README-c.md' ]] && continue

    src_f="$src_root/$rel"
    dst_f="$dst_root/$rel"
    io_copy_file "$src_f" "$dst_f"
  done < <(cd "$src_root" && find . -type f -print0)

  # standalone 使用 README-s.md 作为目标 README.md；缺失则回退 README.md
  local readme_src="$src_root/README-s.md"
  [[ -f "$readme_src" ]] || readme_src="$src_root/README.md"
  if [[ -f "$readme_src" ]]; then
    io_copy_file "$readme_src" "$dst_root/README.md"
  fi

  info "    application/ 全量同步完成"
}

# 步骤 1b：application/ §2.1 核心子集（central + type=application）
install_application_subset_to_docs() {
  local src_root="${CFG[source_dir]}"
  local dst_root="${CFG[docs_abs]}"

  [[ -d "$src_root" ]] || error "未找到 application 目录: $src_root"
  info ">>> 初始化 application/（§2.1 核心子集，central + type=application）→ 目标"
  info "    源:   $src_root"
  info "    目标: $dst_root"

  local d rel src_f dst_f
  for d in knowledge specs; do
    [[ -d "$src_root/$d" ]] || { warn "§2.1 子集：跳过缺失目录 application/$d"; continue; }
    while IFS= read -r -d '' rel; do
      rel="${rel#./}"
      [[ -z "$rel" ]] && continue
      src_f="$src_root/$d/$rel"
      dst_f="$dst_root/$d/$rel"
      io_copy_file "$src_f" "$dst_f"
    done < <(cd "$src_root/$d" && find . -type f -print0)
  done

  local base
  for base in index.md knowledge-links.yaml DESIGN.md; do
    [[ -f "$src_root/$base" ]] || continue
    io_copy_file "$src_root/$base" "$dst_root/$base"
  done

  # central 使用 README-c.md 作为目标 README.md；缺失则回退 README.md
  local readme_src="$src_root/README-c.md"
  [[ -f "$readme_src" ]] || readme_src="$src_root/README.md"
  if [[ -f "$readme_src" ]]; then
    io_copy_file "$readme_src" "$dst_root/README.md"
  fi

  info "    application/ §2.1 子集同步完成"
}

# 步骤 1c：仓库顶层 system/、solution/ 或 company/ → 目标
# 用法：install_org_template_to_docs <label> <src_root>
install_org_template_to_docs() {
  local label="$1" src_root="$2"
  local dst_root="${CFG[docs_abs]}"

  [[ -d "$src_root" ]] || error "未找到 ${label}/ 目录: $src_root"
  info ">>> 初始化 ${label}/ → 目标文档目录（${label} 知识库根）"
  info "    源:   $src_root"
  info "    目标: $dst_root"

  local rel src_f dst_f
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    src_f="$src_root/$rel"
    dst_f="$dst_root/$rel"
    io_copy_file "$src_f" "$dst_f"
  done < <(cd "$src_root" && find . -type f -print0)

  info "    ${label}/ 同步完成"
}

# 建联改由 /docs-link 技能（agent-install 已装技能树）；不再向目标仓拷贝 docs-link 脚本。

# 步骤 1：重装时保留已有 knowledge-links.yaml（含 type:parent / type:meta 与向下 child）
_DOCS_INSTALL_LINKS_STASH=""

docs_install_stash_knowledge_links() {
  local src="${CFG[docs_abs]}/knowledge-links.yaml"
  knowledge_links_validate_file_target "$src" || return 1
  [[ "${CFG[dry_run]}" == 0 ]] || return 0
  _DOCS_INSTALL_LINKS_STASH=""
  [[ -n "${CFG[docs_abs]}" && -f "$src" ]] || return 0
  _DOCS_INSTALL_LINKS_STASH="$(mktemp "${TMPDIR:-/tmp}/knowledge-links.XXXXXX")"
  cp -p "$src" "$_DOCS_INSTALL_LINKS_STASH"
}

docs_install_restore_knowledge_links() {
  [[ "${CFG[dry_run]}" == 0 ]] || return 0
  [[ -n "${_DOCS_INSTALL_LINKS_STASH:-}" && -f "$_DOCS_INSTALL_LINKS_STASH" ]] || return 0
  mkdir -p "${CFG[docs_abs]}"
  mv "$_DOCS_INSTALL_LINKS_STASH" "${CFG[docs_abs]}/knowledge-links.yaml"
  _DOCS_INSTALL_LINKS_STASH=""
}

# 在文档目录/knowledge-links.yaml upsert 恰好一条 type:meta（指向装机源仓）
# doc_dir = 目标 KNOWLEDGE_TYPE（= CFG[type]）；多条时保留第一条并覆盖，丢弃其余 meta
docs_install_upsert_knowledge_meta() {
  local links_file meta_repo meta_path child_kind parent_kind
  local -a repos=() paths=() doc_dirs=() apps=() labels=() types=()
  local -a nrepos=() npaths=() ndirs=() napps=() nlabels=() ntypes=()
  local i meta_seen=0

  [[ -n "${CFG[docs_abs]:-}" ]] || return 0
  links_file="${CFG[docs_abs]}/knowledge-links.yaml"
  knowledge_links_validate_file_target "$links_file" || return 1

  meta_repo="${CFG[meta_repo]}"
  meta_path="${CFG[meta_path_stored]}"

  case "${CFG[type]}" in
    application) child_kind='app'; parent_kind='sys' ;;
    system)      child_kind='app'; parent_kind='solution' ;;
    solution)    child_kind='sys'; parent_kind='company' ;;
    company)     child_kind='solution'; parent_kind='none' ;;
    *) error "内部错误：未知 type=${CFG[type]}" ;;
  esac

  if [[ "${CFG[dry_run]}" == '1' ]]; then
    log "[dry-run] upsert type:meta → ${links_file}"
    log "[dry-run]   repository=${meta_repo}"
    log "[dry-run]   path=${meta_path}"
    log "[dry-run]   doc_dir=${CFG[type]}"
    return 0
  fi

  knowledge_links_load_into_arrays "$links_file" paths repos doc_dirs apps labels types
  for i in "${!paths[@]}"; do
    if [[ "${types[i]:-child}" == 'meta' ]]; then
      if [[ "$meta_seen" -eq 0 ]]; then
        nrepos+=("$meta_repo")
        npaths+=("$meta_path")
        ndirs+=("${CFG[type]}")
        napps+=('')
        nlabels+=('')
        ntypes+=('meta')
        meta_seen=1
      fi
      continue
    fi
    nrepos+=("${repos[i]:-}")
    npaths+=("${paths[i]}")
    ndirs+=("${doc_dirs[i]:-}")
    napps+=("${apps[i]:-}")
    nlabels+=("${labels[i]:-}")
    ntypes+=("${types[i]:-child}")
  done
  if [[ "$meta_seen" -eq 0 ]]; then
    nrepos+=("$meta_repo")
    npaths+=("$meta_path")
    ndirs+=("${CFG[type]}")
    napps+=('')
    nlabels+=('')
    ntypes+=('meta')
  fi

  DRY=0 knowledge_links_write_entries "$links_file" nrepos npaths ndirs napps nlabels ntypes \
    "$child_kind" "$parent_kind" || return 1
  info "已登记 type:meta → ${links_file}（doc_dir=${CFG[type]}）"
}

docs_install_copy_templates() {
  case "${CFG[type]}" in
    application)
      if [[ "${CFG[mode]}" == 'central' ]]; then
        install_application_subset_to_docs
      else
        install_application_full_to_docs
      fi
      ;;
    system|solution|company) install_org_template_to_docs "${CFG[type]}" "${CFG[source_dir]}" ;;
    *)       error "内部错误：未知 type=${CFG[type]}" ;;
  esac
}

# 路径已由纯预检验证；复用共享序列化规则，避免 writer 的实存目录要求。
docs_install_write_docsconfig() {
  local knowledge_type=''
  [[ "${CFG[scope]}" != knowledge ]] || knowledge_type="${CFG[type]}"
  if [[ "${CFG[dry_run]}" == 1 ]]; then
    printf 'Would write %s:\n' "${CFG[config_file]}"
    docsconfig_print_kv_block "${CFG[repo_dir]}" "${CFG[doc_dir]}" "$knowledge_type" "${CFG[agent_root]}" "${CFG[agent_dir]}"
    return 0
  fi
  mkdir -p "${CFG[target_dir]}"
  (
    umask 022
    docsconfig_print_kv_block "${CFG[repo_dir]}" "${CFG[doc_dir]}" "$knowledge_type" "${CFG[agent_root]}" "${CFG[agent_dir]}" >"${CFG[config_file]}"
  )
}
