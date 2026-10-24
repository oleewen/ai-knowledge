# 元库来源与发布快照；入口持有 META_* / VERSION_* 状态。

detect_version_range() {
  local docs_root="${1:?docs_root}"
  local design_file="${docs_root%/}/DESIGN.md" current latest from_sha to_sha
  [[ -f "$design_file" ]] || return 0
  current="$(sed -n 's/^version:[[:space:]]*\([^[:space:]]*\).*/\1/p' "$design_file" | head -1)"
  [[ -n "$current" ]] || return 0
  current="$(version_normalize "$current")" || error "DESIGN.md 版本格式无效: $current"
  [[ -n "$META_GIT_REPO" ]] || error "版本增量需要元库 Git 发布历史；当前元库不是 Git 仓库"
  latest="$(version_latest_from_log "$META_GIT_REPO" "$META_REVISION" || true)"
  [[ -n "$latest" ]] || error "元库所选 ref 缺少目标版本发布提交: $META_REVISION"
  to_sha="$(version_commit_sha "$META_GIT_REPO" "$latest" "$META_REVISION" || true)"
  from_sha="$(version_commit_sha "$META_GIT_REPO" "$current" "$META_REVISION" || true)"
  [[ -n "$to_sha" ]] || error "找不到目标版本提交: $latest"
  [[ -n "$from_sha" ]] || error "找不到当前版本提交: $current"
  git -C "$META_GIT_REPO" merge-base --is-ancestor "$from_sha" "$to_sha" \
  || error "当前版本不是目标版本的祖先，拒绝增量升级: $current -> $latest"
  VERSION_FROM="$current"
  VERSION_TO="$latest"
  VERSION_FROM_SHA="$from_sha"
  VERSION_TO_SHA="$to_sha"
  info "版本增量: $VERSION_FROM -> $VERSION_TO (${from_sha}..${to_sha})"
}

version_path_changed() {
  local rel="$1"
  [[ -z "$VERSION_FROM_SHA" ]] && return 0
  local rc=0
  git -C "$META_GIT_REPO" diff --quiet "$VERSION_FROM_SHA" "$VERSION_TO_SHA" -- "$META_DOC_DIR/$rel" || rc=$?
  case "$rc" in
    0) return 1 ;;
    1) return 0 ;;
    *) error "无法计算元库版本差异: $rel (git diff=$rc)" ;;
  esac
}

meta_git_is_dirty() {
  local repo="$1"
  [[ -n "$(git -C "$repo" status --porcelain 2>/dev/null || true)" ]]
}

# ref 非空 = 显式 --ref；空 = 未传 --ref
resolve_meta_tree() {
  local meta_path="$1"
  local meta_repo="$2"
  local ref="$3"
  local work archive_ref clone_ref

  if [[ -e "$meta_path/.git" ]]; then
    if meta_git_is_dirty "$meta_path"; then
      error "meta path 工作区有未提交改动，拒绝升级: ${meta_path}（请先提交或清理）"
    fi
    work="$(mktemp -d "${TMPDIR:-/tmp}/docs-upgrade-meta.XXXXXX")"
    if [[ -n "$ref" ]]; then
      info ">>> git fetch @ ${meta_path} (ref=${ref})"
      git -C "$meta_path" fetch --quiet origin "$ref" 2>/dev/null \
      || git -C "$meta_path" fetch --quiet origin 2>/dev/null \
      || warn "git fetch 失败，将尝试本地 ref: ${ref}"
      if git -C "$meta_path" rev-parse --verify "origin/$ref" >/dev/null 2>&1; then
        archive_ref="origin/$ref"
      elif git -C "$meta_path" rev-parse --verify "$ref" >/dev/null 2>&1; then
        archive_ref="$ref"
      else
        rm -rf "$work"
        error "meta path 找不到 ref（origin/${ref} 与本地 ${ref} 均无）: ${meta_path}"
      fi
      info ">>> meta 结构源: git archive ${archive_ref} @ ${meta_path}"
    else
      archive_ref=HEAD
      info ">>> meta 结构源: git archive HEAD @ ${meta_path} (当前分支，未传 --ref)"
    fi
    META_ROOT="$work"
    META_CLEANUP="$work"
    META_GIT_REPO="$meta_path"
    META_REVISION="$(git -C "$meta_path" rev-parse --verify "${archive_ref}^{commit}")"
    detect_version_range "$doc_abs"
    git -C "$meta_path" archive "${VERSION_TO_SHA:-$META_REVISION}" | tar -x -C "$work"
  elif [[ -d "$meta_path" && ( -d "$meta_path/application" || -d "$meta_path/system" || -d "$meta_path/solution" || -d "$meta_path/company" ) ]]; then
    META_ROOT="$meta_path"
    META_CLEANUP=""
    detect_version_range "$doc_abs"
  elif [[ -n "$meta_repo" ]]; then
    clone_ref="${ref:-main}"
    work="$(mktemp -d "${TMPDIR:-/tmp}/docs-upgrade-clone.XXXXXX")"
    info ">>> clone ${meta_repo} @ ${clone_ref} -> ${work}"
    META_CLONE_CLEANUP="$work"
    git clone --branch "$clone_ref" "$meta_repo" "$work" \
    || error "无法 clone 元库指定 ref: $clone_ref"
    META_GIT_REPO="$work"
    META_REVISION="$(git -C "$work" rev-parse HEAD)"
    detect_version_range "$doc_abs"
    META_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/docs-upgrade-meta.XXXXXX")"
    META_CLEANUP="$META_ROOT"
    git -C "$work" archive "${VERSION_TO_SHA:-$META_REVISION}" | tar -x -C "$META_ROOT"
  else
    error "meta path 不可用且无 repository: path=${meta_path}"
  fi
}

resolve_meta_root() {
  local links_file="$1"
  local -a paths=() repos=() doc_dirs=() apps=() labels=() types=()
  local i meta_idx=-1 meta_count=0
  local meta_path meta_repo meta_doc_dir ref

  if [[ -n "$META_PATH_OVERRIDE" ]]; then
    if [[ "$META_PATH_OVERRIDE" == '${WORK_SPACE}' || "$META_PATH_OVERRIDE" == '${WORK_SPACE}/'* ]]; then
      meta_path="$(knowledge_link_expand_stored_path "$META_PATH_OVERRIDE" "$links_file")"
    else
      local stored_override
      stored_override="$(knowledge_link_stored_path_from_absolute "$META_PATH_OVERRIDE" "$links_file")"
      meta_path="$(knowledge_link_expand_stored_path "$stored_override" "$links_file")"
    fi
    meta_repo=""
    meta_doc_dir="${KNOWLEDGE_TYPE}"
    ref="${REF_OVERRIDE:-}"
  else
    [[ -f "$links_file" ]] || error "缺少 knowledge-links.yaml: $links_file（请先装机或补 type: meta）"
    knowledge_links_load_into_arrays "$links_file" paths repos doc_dirs apps labels types
    for ((i = 0; i < ${#types[@]}; i++)); do
      if [[ "${types[i]}" == 'meta' ]]; then
        meta_count=$((meta_count + 1))
        meta_idx=$i
      fi
    done
    [[ "$meta_count" -eq 1 ]] || error "须恰好一条 type: meta（当前 ${meta_count}）。可 --meta-path 覆盖，或修复 links / 重跑 docs-install upsert"
    meta_path="$(knowledge_link_expand_stored_path "${paths[meta_idx]}" "$links_file")"
    meta_repo="${repos[meta_idx]}"
    meta_doc_dir="${doc_dirs[meta_idx]:-$KNOWLEDGE_TYPE}"
    ref="${REF_OVERRIDE:-}"
  fi

  [[ "$meta_doc_dir" == "$KNOWLEDGE_TYPE" ]] \
  || error "元库模板目录与本库层级不一致: dir=${meta_doc_dir} KNOWLEDGE_TYPE=${KNOWLEDGE_TYPE}；请修正 knowledge-links.yaml 中 type: meta 条目的 dir"
  META_DOC_DIR="$meta_doc_dir"
  META_ORIGIN="${meta_repo:-$meta_path}"
  resolve_meta_tree "$meta_path" "$meta_repo" "$ref"
  META_SRC="${META_ROOT%/}/${META_DOC_DIR}"
  [[ -d "$META_SRC" ]] || error "元库缺少模板目录: $META_SRC"
  info "结构源: $META_SRC"
}

cleanup() {
  if [[ -n "${BACKUP_SCAN_FILE:-}" && -f "$BACKUP_SCAN_FILE" ]]; then
    rm -f "$BACKUP_SCAN_FILE"
  fi
  if [[ -n "${META_CLEANUP:-}" && -d "$META_CLEANUP" ]]; then
    rm -rf "$META_CLEANUP"
  fi
  if [[ -n "${META_CLONE_CLEANUP:-}" && -d "$META_CLONE_CLEANUP" ]]; then
    rm -rf "$META_CLONE_CLEANUP"
  fi
}
