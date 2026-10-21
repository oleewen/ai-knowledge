# 扫描、分类与动作清单；不写入目标文件。

normalize_text() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  if command -v perl >/dev/null 2>&1; then
    perl -pe 's/\r\n/\n/g; s/\r/\n/g; s/[ \t]+$//g' "$f"
  else
    tr -d '\r' <"$f" | sed -E 's/[[:blank:]]+$//'
  fi
}

files_equal_normalized() {
  local a="$1" b="$2"
  [[ -f "$a" && -f "$b" ]] || return 1
  local ha hb
  ha="$(normalize_text "$a" | shasum -a 256 | awk '{print $1}')"
  hb="$(normalize_text "$b" | shasum -a 256 | awk '{print $1}')"
  [[ "$ha" == "$hb" ]]
}

# 顶层遗留联邦槽位名（不含 application-slots / system-slots）
is_legacy_federal_slot_rel() {
  local rel="$1"
  local top="${rel%%/*}"
  case "$top" in
    application-slots|system-slots) return 1 ;;
    application-*|system-*) return 0 ;;
  esac
  return 1
}

# 根级 DESIGN.md：元库模板 SSOT；已改则整文件覆盖（不走 H2 结构重填）
is_root_design_rel() {
  [[ "$1" == 'DESIGN.md' ]]
}

is_excluded_meta_rel() {
  local rel="$1"
  is_legacy_federal_slot_rel "$rel" && return 0
  case "$rel" in
    knowledge-links.yaml) return 0 ;;
    README-s.md|README-c.md) return 0 ;;
  esac
  return 1
}

note_ignored_legacy_slot_dir() {
  local rel="$1" top
  is_legacy_federal_slot_rel "$rel" || return 0
  top="${rel%%/*}"
  [[ -n "${IGNORED_SLOT_SEEN[$top]:-}" ]] && return 0
  IGNORED_SLOT_SEEN["$top"]=1
  IGNORED_SLOT_DIRS+=("$top")
}

# 路径自身或任一已存在祖先为软链 → 跳过
path_is_or_under_symlink() {
  local root="$1" rel="$2"
  local cur="${root%/}" part rest="$rel"
  [[ -z "$rel" ]] && return 1
  while [[ -n "$rest" ]]; do
    part="${rest%%/*}"
    if [[ "$rest" == */* ]]; then
      rest="${rest#*/}"
    else
      rest=""
    fi
    cur="${cur}/${part}"
    if [[ -L "$cur" ]]; then
      return 0
    fi
    [[ -e "$cur" ]] || return 1
  done
  return 1
}

# 只在对应父目录找真实实例；命中示例祖先目录时，其下缺失文件一并跳过。
# 调用前已排除目标路径及祖先软链；候选软链和目录内的实体软链另行排除。
existing_instance_for_example() {
  local root="${1%/}" rest="$2" parent="" part stem prefix peer name is_dir
  while [[ -n "$rest" ]]; do
    part="${rest%%/*}"
    if [[ "$rest" == */* ]]; then
      rest="${rest#*/}"
      is_dir=1
      stem="$part"
    else
      rest=""
      is_dir=0
      [[ "$part" == *.md ]] || return 1
      stem="${part%.md}"
    fi
    case "$stem" in
      *-EXAMPLE|*-EXAMPLE-*)
        prefix="${stem%%-EXAMPLE*}"
        if [[ -n "$prefix" ]]; then
          for peer in "$root/${parent:+$parent/}${prefix}-"*; do
            name="${peer##*/}"
            [[ "$name" == *EXAMPLE* || -L "$peer" ]] && continue
            if [[ "$is_dir" == 1 ]]; then
              [[ "$name" != "$prefix-" && -d "$peer" && -f "$peer/$name.md" && ! -L "$peer/$name.md" ]] || continue
              printf '%s/%s.md\n' "${peer#"$root/"}" "$name"
            else
              [[ "$name" == *.md && "${name%.md}" != "$prefix-" && -f "$peer" ]] || continue
              printf '%s\n' "${peer#"$root/"}"
            fi
            return 0
          done
        fi
      ;;
    esac
    parent="${parent:+$parent/}$part"
  done
  return 1
}

meta_src_for_local_rel() {
  local src_root="$1" local_rel="$2"
  if [[ "$local_rel" == 'README.md' ]]; then
    if [[ -f "$src_root/README-s.md" ]]; then
      printf '%s' "$src_root/README-s.md"
      return 0
    fi
    if [[ -f "$src_root/README.md" ]]; then
      printf '%s' "$src_root/README.md"
      return 0
    fi
    return 1
  fi
  if [[ -f "$src_root/$local_rel" ]]; then
    printf '%s' "$src_root/$local_rel"
    return 0
  fi
  return 1
}

note_skip_symlink() {
  local rel="$1"
  [[ -n "${SKIP_SYMLINK_SEEN[$rel]:-}" ]] && return 0
  SKIP_SYMLINK_SEEN["$rel"]=1
  SKIP_SYMLINK_LIST+=("$rel")
}

scan_upgrade_tree() {
  local rel local_rel src_f dst_f instance_rel
  # 本库软链清单（find 不跟随目录软链；另列 -type l）
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    if is_legacy_federal_slot_rel "$rel"; then
      note_ignored_legacy_slot_dir "$rel"
      continue
    fi
    note_skip_symlink "$rel"
  done < <(cd "${doc_abs}" && find . -type l -print0)

  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    if is_legacy_federal_slot_rel "$rel"; then
      note_ignored_legacy_slot_dir "$rel"
      continue
    fi
    local_rel="$rel"
    if [[ "$KNOWLEDGE_TYPE" == application && "$rel" == README-s.md ]]; then
      local_rel=README.md
    elif [[ "$KNOWLEDGE_TYPE" == application && "$rel" == README.md && -f "$META_SRC/README-s.md" ]]; then
      continue
    else
      is_excluded_meta_rel "$rel" && continue
    fi
    version_path_changed "$rel" || continue
    src_f="$META_SRC/$rel"
    dst_f="${doc_abs%/}/$local_rel"

    if path_is_or_under_symlink "${doc_abs%/}" "$local_rel"; then
      note_skip_symlink "$local_rel"
      continue
    fi

    if [[ ! -e "$dst_f" ]]; then
      if instance_rel="$(existing_instance_for_example "${doc_abs%/}" "$local_rel")"; then
        SKIP_LIST+=("$local_rel (同类实例已存在: $instance_rel)")
        continue
      fi
      ADD_LIST+=("$local_rel")
      continue
    fi
    if [[ -f "$dst_f" && -f "$src_f" ]]; then
      if files_equal_normalized "$src_f" "$dst_f"; then
        SKIP_LIST+=("$local_rel")
      else
        if is_root_design_rel "$local_rel"; then
          OVERWRITE_LIST+=("$local_rel")
        elif [[ "$local_rel" == *.md ]]; then
          RESTRUCTURE_LIST+=("$local_rel")
        else
          SKIP_LIST+=("$local_rel (非 md 已改·本库胜)")
        fi
      fi
    fi
  done < <(cd "$META_SRC" && find . -type f -print0)

  local -A META_RELS=()
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    if is_legacy_federal_slot_rel "$rel"; then
      note_ignored_legacy_slot_dir "$rel"
      continue
    fi
    is_excluded_meta_rel "$rel" && continue
    META_RELS["$rel"]=1
  done < <(cd "$META_SRC" && find . -type f -print0)
  META_RELS['README.md']=1

  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    [[ "$rel" == 'knowledge-links.yaml' ]] && continue
    if is_legacy_federal_slot_rel "$rel"; then
      note_ignored_legacy_slot_dir "$rel"
      continue
    fi
    if path_is_or_under_symlink "${doc_abs%/}" "$rel"; then
      note_skip_symlink "$rel"
      continue
    fi
    if [[ -z "${META_RELS[$rel]:-}" ]]; then
      LOCAL_ONLY_LIST+=("$rel")
    fi
  done < <(cd "${doc_abs}" && find . -type f -print0)
}

print_bucket() {
  local title="$1"
  shift
  local -a items=("$@")
  printf '\n== %s (%d) ==\n' "$title" "${#items[@]}"
  local it
  for it in "${items[@]+"${items[@]}"}"; do
    printf ' %s\n' "$it"
  done
}

print_upgrade_plan() {
  info "doc_abs=$doc_abs KNOWLEDGE_TYPE=$KNOWLEDGE_TYPE dry_run=$DRY_RUN apply_scaffold=$APPLY_SCAFFOLD"
  print_bucket '忽略遗留槽位' "${IGNORED_SLOT_DIRS[@]+"${IGNORED_SLOT_DIRS[@]}"}"
  print_bucket '跳过软链' "${SKIP_SYMLINK_LIST[@]+"${SKIP_SYMLINK_LIST[@]}"}"
  print_bucket '新增骨架' "${ADD_LIST[@]+"${ADD_LIST[@]}"}"
  print_bucket '跳过' "${SKIP_LIST[@]+"${SKIP_LIST[@]}"}"
  print_bucket '结构重填' "${RESTRUCTURE_LIST[@]+"${RESTRUCTURE_LIST[@]}"}"
  print_bucket '整文件覆盖' "${OVERWRITE_LIST[@]+"${OVERWRITE_LIST[@]}"}"
  print_bucket '本库独有(保留)' "${LOCAL_ONLY_LIST[@]+"${LOCAL_ONLY_LIST[@]}"}"
}
