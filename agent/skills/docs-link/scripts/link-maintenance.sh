#!/usr/bin/env bash
# 已登记槽位维护；由 docs-link.sh source，不写清单、不执行 Git 更新。

# 只分解清单，不提前展开 path；每条的错误在选中后校验，保证全量继续。
# 沿用共享清单的单行字段格式，结构错误不能被当作空清单。
maintenance_load() {
  local file="$1" prefix="$2" line key value index=-1 header=0 empty_list=0
  local list_indent=-1 field_indent=0 indent gap
  local item_pattern='^( *)-( +)([a-z_]+):[[:space:]]*(.*)$'
  local field_pattern='^( +)([a-z_]+):[[:space:]]*(.*)$'
  [[ -f "$file" && ! -L "$file" ]] || die "缺少普通清单文件: $file"
  local -n paths="${prefix}p" repos="${prefix}r" dirs="${prefix}d" names="${prefix}n" types="${prefix}t" errors="${prefix}e"
  paths=(); repos=(); dirs=(); names=(); types=(); errors=()
  local -A keys=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^links:[[:space:]]*(\[\])?[[:space:]]*(#.*)?$ ]]; then
      ((header == 0)) || die "重复 links: $file"
      [[ -z "${BASH_REMATCH[1]:-}" ]] || empty_list=1
      header=1; continue
    fi
    ((header)) || die "清单缺少 links: $file"
    ((empty_list == 0)) || die "空 links 列表后不能追加条目: $file"
    if [[ "$line" =~ $item_pattern ]]; then
      indent="${BASH_REMATCH[1]}"; gap="${BASH_REMATCH[2]}"
      key="${BASH_REMATCH[3]}"; value="${BASH_REMATCH[4]}"
      ((list_indent >= 0)) || list_indent=${#indent}
      ((${#indent} == list_indent)) || die "清单条目缩进不一致或存在嵌套列表: $file"
      field_indent=$((${#indent} + 1 + ${#gap}))
      index=$((index + 1)); keys=()
      paths[index]=''; repos[index]=''; dirs[index]=''; names[index]=''; types[index]=''; errors[index]=''
    elif [[ "$line" =~ $field_pattern && "$index" -ge 0 ]]; then
      indent="${BASH_REMATCH[1]}"
      key="${BASH_REMATCH[2]}"; value="${BASH_REMATCH[3]}"
      # 只读条目的直接标量字段；不能借嵌套对象补齐登记身份。
      ((${#indent} == field_indent)) || die "清单字段缩进不一致或存在嵌套对象: $file"
    else
      die "无法解析清单行: $file: $line"
    fi
    if [[ -n "${keys[$key]:-}" ]]; then
      # type 决定检查范围；重复时无法安全按 child 过滤。
      [[ "$key" != type ]] || die "重复 type 导致清单类型歧义: $file"
      errors[index]+="重复字段 ${key}；"
    fi
    keys[$key]=1
    value="$(_yaml_unquote "$value")"
    case "$key" in
      path) paths[index]="$value" ;;
      repository) repos[index]="$value" ;;
      dir) dirs[index]="$value" ;;
      name) names[index]="$value" ;;
      type) types[index]="$value" ;;
      doc_dir|app_name|sys_name|company_name|solution_name|app_label|sys_label|company_label|solution_label)
        errors[index]+="旧字段 ${key}；" ;;
    esac
  done < "$file"
  ((header)) || die "清单缺少 links: $file"
  for index in "${!types[@]}"; do
    case "${types[index]}" in parent|child|meta) ;; *) die "清单 type 缺失或非法: $file" ;; esac
  done
}

maintenance_entry() {
  local prefix="$1" index="$2" file="$3"
  local -n paths="${prefix}p" repos="${prefix}r" dirs="${prefix}d" names="${prefix}n" errors="${prefix}e"
  [[ -z "${errors[index]}" ]] || die "清单条目非法: ${errors[index]} ($file)"
  [[ -n "${paths[index]}" && -n "${repos[index]}" && -n "${dirs[index]}" && -n "${names[index]}" ]] || die "清单条目缺少 path/repository/dir/name: $file"
  knowledge_link_value_looks_like_git_remote "${repos[index]}" || die "repository 须为 Git remote URL: $file"
  docsconfig_validate_doc_dir "${dirs[index]}" || die "非法 dir: $file"
}

maintenance_one() (
  # 子进程独立退出；调用方用状态码汇总，显式检查所有外部命令。
  local index="$1" other root top actual trepo='' tdoc='' tdir='' tar='' tkt='' parents=0 parent=-1
  local slots="$sdoc/$target_kind-slots" name slot expected parent_root
  maintenance_entry s "$index" "$LIST_FILE"
  name="$(validate_name "${sn[index]}")" || exit 1
  for other in "${!sp[@]}"; do
    [[ "$other" == "$index" || "${st[other]}" != child ]] && continue
    [[ "${sr[other]%/}" != "${sr[index]%/}" && "${sn[other],,}" != "$name" ]] || die 'child identity/name 重复'
  done
  root="$(knowledge_link_expand_stored_path "${sp[index]}" "$LIST_FILE")" || exit 1
  [[ -d "$root" ]] || die "登记仓库缺失: $root"
  top="$(git -C "$root" rev-parse --show-toplevel 2>/dev/null)" || die "目标不是 Git 仓库: $root"
  [[ "$(cd "$top" && pwd -P)" == "$root" ]] || die "登记 path 必须是目标 Git 根: $root"
  actual="$(knowledge_link_git_remote_url_prefer_origin "$root")" || die "目标缺少 remote: $root"
  [[ "${actual%/}" == "${sr[index]%/}" ]] || die "目标 remote 与登记不符: $root"
  docsconfig_abs_for_config "$root/.docsconfig" trepo tdoc tdir tar tkt || die "无法解析目标 .docsconfig: $root"
  docsconfig_validate_owner_matches_repo "$root" "$trepo" || die "目标配置归属不符: $root"
  [[ "$tkt" == "$target_kind" ]] || die "目标须为 $target_kind（收到 $tkt）"
  [[ "$tdir" == "${sd[index]}" ]] || die "登记 dir 与目标 DOC_DIR 不符: $root"
  tdoc="$(doc_root_in_repo "$root" "$tdoc")" || exit 1
  [[ -d "$tdoc" ]] || die "目标文档目录缺失: $tdoc"
  local target_list="$tdoc/knowledge-links.yaml"
  local -a tr=() tp=() td=() tn=() tt=() te=()
  maintenance_load "$target_list" t
  for other in "${!tp[@]}"; do
    [[ "${tt[other]}" == parent ]] || continue
    ((parents+=1)); parent=$other
  done
  ((parents == 1)) || die "目标须登记唯一 parent: $target_list"
  maintenance_entry t "$parent" "$target_list"
  [[ "${tr[parent]%/}" == "${source_remote%/}" && "${td[parent]}" == "$sdir" ]] || die "parent repository/dir 未指向源库: $target_list"
  parent_root="$(knowledge_link_expand_stored_path "${tp[parent]}" "$target_list")" || exit 1
  [[ "$parent_root" == "$SRC_ROOT" ]] || die "parent path 未指向源库: $target_list"
  [[ ! -L "$slots" ]] || die "槽位父目录不能是软链: $slots"
  [[ ! -e "$slots" || -d "$slots" ]] || die "槽位父路径不是目录: $slots"
  slot="$slots/$target_kind-$name"
  if [[ -L "$slot" ]]; then
    # resolve 跟随相对链与链式目标；正确的相对链保持原字节。
    actual="$(python3 -B - "$slot" <<'PY'
from pathlib import Path
import sys
try:
    print(Path(sys.argv[1]).resolve())
except (OSError, RuntimeError):
    pass
PY
)" || exit 1
    if [[ "$actual" == "$tdoc" ]]; then
      printf '[正常] %s → %s\n' "$slot" "$tdoc"
      exit 0
    fi
  elif [[ -e "$slot" ]]; then
    die "槽位被普通文件/目录占用，保留并停止: $slot"
  fi
  [[ "$CMD" == repair ]] || die "槽位缺失或指向不符: $slot → $tdoc"
  if ((DRY)); then
    printf '[dry-run] 将修复软链: %s → %s\n' "$slot" "$tdoc"
    exit 0
  fi
  mkdir -p "$slots" || die "无法创建槽位目录: $slots"
  # -n 防止跟随旧目录软链；-f 只用于已经确认是软链的路径。
  if [[ -L "$slot" ]]; then
    ln -sfn "$tdoc" "$slot" || die "修复软链失败: $slot"
  else
    ln -s "$tdoc" "$slot" || die "创建软链失败: $slot"
  fi
  printf '[已修复] %s → %s\n' "$slot" "$tdoc"
)

maintenance_main() {
  docsconfig_validate_owner_matches_repo "$SRC_ROOT" "$srepo" || die '源配置归属不符'
  [[ -d "$sdoc" ]] || die "源文档目录缺失: $sdoc"
  source_remote="$(knowledge_link_git_remote_url_prefer_origin "$SRC_ROOT")" || die '源仓库缺少 Git remote URL'
  knowledge_link_value_looks_like_git_remote "$source_remote" || die '源 repository 须为 Git remote URL'
  local -a se=() selected=()
  local index root requested='' failures=0
  maintenance_load "$LIST_FILE" s
  if [[ -n "$TARGET_RAW" ]] && ! knowledge_link_value_looks_like_git_remote "$TARGET_RAW"; then
    requested="$(normalize_target_repo_root "$TARGET_RAW")" || die '无法解析 target'
  fi
  for index in "${!sp[@]}"; do
    [[ "${st[index]}" == child ]] || continue
    if [[ -z "$TARGET_RAW" ]]; then
      selected+=("$index")
    elif [[ -z "$requested" ]]; then
      [[ "${sr[index]%/}" != "${TARGET_RAW%/}" ]] || selected+=("$index")
    else
      # 不读取候选 checkout remote；唯一合法匹配是登记 path。
      root="$(knowledge_link_expand_stored_path "${sp[index]}" "$LIST_FILE" 2>/dev/null)" || continue
      [[ "$root" != "$requested" ]] || selected+=("$index")
    fi
  done
  if [[ -n "$TARGET_RAW" ]]; then
    ((${#selected[@]} == 1)) || die 'target 须精确匹配唯一已登记 child 的 path 或 repository'
  elif ((${#selected[@]} == 0)); then
    printf '[检查] 无 child 登记（0 项）\n'
    return 0
  fi
  for index in "${selected[@]}"; do
    printf '[检查] child=%s repository=%s path=%s\n' "${sn[index]}" "${sr[index]}" "${sp[index]}"
    if maintenance_one "$index"; then :; else ((failures+=1)); fi
  done
  printf '[汇总] child=%d 成功=%d 失败=%d\n' "${#selected[@]}" "$((${#selected[@]} - failures))" "$failures"
  ((failures == 0))
}
