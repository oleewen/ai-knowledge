# 写盘与原字节备份；入口持有 BACKUP_ROOT。

backup_file_to_stamp() {
  local src="$1" rel="$2" dst="${BACKUP_ROOT}/$2"
  [[ -f "$src" ]] || return 0
  path_is_or_under_symlink "$doc_abs" "$rel" && return 0
  # 同次运行只保留第一份原文；不让后续写入覆盖备份。
  [[ ! -e "$dst" ]] || return 0
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

ensure_backup_root() {
  UPGRADE_STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
  mkdir -p "${repo_abs%/}/.docs-init"
  BACKUP_ROOT="$(mktemp -d "${repo_abs%/}/.docs-init/upgrade-${UPGRADE_STAMP}-XXXXXX")"
  info "备份根: $BACKUP_ROOT"
}

backup_existing_targets() {
  local file rel
  # 文本安全超集：覆盖全树路径重写和根 README 注记，也包含未实际改动的文本。
  # 排除目录与共享重写一致；find 不跟随软链，新 scaffold 尚不存在。
  # 先同步枚举并检查退出码；进程替换会吞掉 find 的失败状态。
  BACKUP_SCAN_FILE="$(mktemp "${TMPDIR:-/tmp}/docs-upgrade-backup-files.XXXXXX")"
  if ! find "$doc_abs" \
    \( -name node_modules -o -name .git -o -name __pycache__ -o -name .venv \
    -o -name .cache -o -name dist -o -name build -o -name target \) \
    -prune -o -type f -print0 >"$BACKUP_SCAN_FILE"; then
    error "无法枚举备份文件，停止升级: $doc_abs"
  fi
  while IFS= read -r -d '' file; do
    is_text_file "$file" || continue
    rel="${file#"${doc_abs%/}/"}"
    backup_file_to_stamp "$file" "$rel"
  done <"$BACKUP_SCAN_FILE"
  for rel in "${RESTRUCTURE_LIST[@]+"${RESTRUCTURE_LIST[@]}"}" "${OVERWRITE_LIST[@]+"${OVERWRITE_LIST[@]}"}"; do
    backup_file_to_stamp "${doc_abs%/}/$rel" "$rel"
  done
}

apply_scaffold() {
  local rel src dst
  ensure_backup_root
  # 全部备份成功后，才开始第一次目标写入。
  backup_existing_targets
  # 与原文备份分开，随机目录避免占用本库合法文件名；失败后保留现场。
  local handoff
  handoff="$(mktemp -d "$BACKUP_ROOT/.source-XXXXXX")"
  mkdir "$handoff/templates"
  cp -R "$META_SRC/." "$handoff/templates/"
  {
    printf 'source=%s\n' "${META_GIT_REPO:-$META_ROOT}"
    printf 'origin=%s\n' "$META_ORIGIN"
    printf 'revision=%s\n' "${VERSION_TO_SHA:-${META_REVISION:-unversioned}}"
    printf 'layer=%s\nfrom=%s\nto=%s\n' "$META_DOC_DIR" "$VERSION_FROM" "$VERSION_TO"
    printf '\n[restructure]\n'
    printf '%s\n' "${RESTRUCTURE_LIST[@]}"
  } > "$handoff/source.txt"
  info "重填交接: $handoff"

  for rel in "${ADD_LIST[@]+"${ADD_LIST[@]}"}" "${OVERWRITE_LIST[@]+"${OVERWRITE_LIST[@]}"}"; do
    if is_legacy_federal_slot_rel "$rel"; then
      warn "跳过遗留槽位骨架（不应出现在新增/覆盖桶）: $rel"
      continue
    fi
    if path_is_or_under_symlink "$doc_abs" "$rel"; then
      warn "跳过软链路径骨架: $rel"
      continue
    fi
    if [[ "$rel" == 'README.md' && "$KNOWLEDGE_TYPE" == 'application' ]]; then
      src="$(meta_src_for_local_rel "$META_SRC" 'README.md' || true)"
    else
      src="$META_SRC/$rel"
    fi
    [[ -n "$src" && -f "$src" ]] || continue
    dst="${doc_abs%/}/$rel"
    mkdir -p "$(dirname "$dst")"
    if is_root_design_rel "$rel" && [[ -n "$VERSION_FROM" ]]; then
      # scaffold 不是整单完成；保留基线，避免重试漏掉尚未完成的正文重填。
      awk -v version="$VERSION_FROM" '/^version:/ { print "version: " version; next } { print }' "$src" >"$dst"
    else
      cp "$src" "$dst"
    fi
    if is_root_design_rel "$rel"; then
      info "整文件覆盖: $rel"
    else
      info "写入骨架: $rel"
    fi
  done
}

finish_scaffold() {
  local mode='consumer' readme="${doc_abs%/}/README.md"
  info "骨架/整文件覆盖写入完成。结构重填与未落位请由 /docs-upgrade Skill 继续。"

  # 空骨架桶也收尾；dry-run 已由入口退出。
  [[ "${KNOWLEDGE_TYPE:-}" == 'meta' ]] && mode='meta'
  if [[ "$mode" != 'meta' ]]; then
    [[ -n "${AGENT_ROOT:-}" && -n "${AGENT_DIR:-}" ]] \
      || error "缺少 AGENT_ROOT/AGENT_DIR，无法建 .agents 软链。请先 docs-install --scope=config 或补充 .docsconfig。"
    ensure_docs_agents_symlink "$doc_abs" "$AGENT_ROOT" "$AGENT_DIR" 0 \
      || error "创建/校正 .agents 软链失败"
  fi
  info ">>> 重写知识库 agent 路径（模式=${mode}）"
  rewrite_agent_path_segment_in_tree "$doc_abs" "$mode"
  if [[ -f "$readme" && ! -L "$readme" ]]; then
    inject_readme_agent_note "$readme" "$mode"
  fi
  info "agent 路径重写完成（模式=${mode}；与 docs-install 同实现）。"
  if [[ -n "$VERSION_TO" ]]; then
    info "当前版本基线保留为 ${VERSION_FROM}；Agent 完成全部重填、未落位处理与校核后，才可将 DESIGN.md version 更新为 ${VERSION_TO}。"
  fi
}
