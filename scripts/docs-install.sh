#!/usr/bin/env bash
# docs-install.sh — 知识库初始化 + .docsconfig（入口脚本，source docs-config.sh）
# 语义应与 scripts/docs-config.sh 对齐；修改时请同步。
set -euo pipefail
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 配置层与 .docsconfig 工具统一下沉到 docs-config.sh
# shellcheck source=./docs-config.sh
source "$SCRIPT_DIR/docs-config.sh"

# ========== docs-install 内联主体（knowledge 路径）==========
# =============================================================================
# § 1  日志函数
# =============================================================================

log()   { printf '%s\n'       "$*" >&2; }
info()  { printf '信息: %s\n'  "$*" >&2; }
warn()  { printf '警告: %s\n'  "$*" >&2; }
error() { printf '错误: %s\n'  "$*" >&2; exit 1; }

# =============================================================================
# § 2  全局状态
# =============================================================================

# 主配置关联数组（单一事实源）
declare -A CFG=(
  [repo_root]="${REPO_ROOT:-}"
  [docs_abs]=""
  [target_dir]=""
  [target_opt]=""
  [mode]="${MODE:-${KINIT_DEFAULT_MODE:-$(cfg_default mode)}}"
  [type]="${TYPE:-}"
  [type_explicit]=0
  [scope]="${SCOPE:-${KINIT_DEFAULT_SCOPE:-k}}"
  [dry_run]="0"
  [force]="${FORCE:-0}"
  [create_project_root]="${CREATE_PROJECT_ROOT:-0}"
  # 运行时填充
  [docs_slash]=""
  [home_abs]=""
)

# 冲突处理全局策略（不放入 CFG，避免混淆）
_CONFLICT_MODE="${CONFLICT_PROMPT_MODE:-}"
_BACKUP_ROOT="${BACKUP_ROOT:-}"

# 本次运行共用时间戳（工程侧与 $HOME 侧备份目录保持一致）
DOC_INIT_STAMP=""

# =============================================================================
# § 3  工具函数（纯函数，无副作用）
# =============================================================================

have_cmd()  { command -v "$1" >/dev/null 2>&1; }
have_perl() { sdx_have_perl; }

# 计算目标工程根相对文档目录路径（带尾斜杠）
compute_docs_rel_slash() {
  local root docs
  root="$(strip_trailing_slash "$1")"
  docs="$(strip_trailing_slash "$2")"
  if   [[ "$docs" == "$root"   ]]; then printf './\n'
  elif [[ "$docs" == "$root"/* ]]; then printf '%s/\n' "${docs#"$root"/}"
  else                                   printf '%s/\n' "$docs"
  fi
}

# =============================================================================
# § 4  IO 工具（副作用函数）
# =============================================================================

# dry-run 感知的命令执行器：dry=1 时只打印，否则执行
run_or_dry() {
  if [[ "${CFG[dry_run]}" == '1' ]]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

ensure_dir() { run_or_dry mkdir -p "$1"; }

# 判断本次运行是否应在同步前重置 DOC_DIR（仅知识库同步 scope）
should_reset_docs_dir_before_sync() {
  [[ -n "${CFG[docs_abs]:-}" ]] || return 1
  case "${CFG[scope]}" in
    knowledge) return 0 ;;
    *)            return 1 ;;
  esac
}

# 获取（或惰性初始化）工程文档侧备份根目录
get_backup_root() {
  if [[ -z "$_BACKUP_ROOT" ]]; then
    local stamp="${DOC_INIT_STAMP:-$(date +%Y-%m-%d_%H-%M-%S)}"
    _BACKUP_ROOT="${CFG[target_dir]:-$PWD}/.docs-init/${stamp}"
  fi
  printf '%s' "$_BACKUP_ROOT"
}

# 实现见 docs-core.sh：sdx_docs_backup_path_to_init
backup_path() {
  local existing="$1"
  sdx_docs_backup_path_to_init "${CFG[target_dir]:-$PWD}" "$existing" "${DOC_INIT_STAMP:-}" "${CFG[dry_run]:-0}"
}

# 询问用户是否覆盖已存在目标（支持全局策略）
# 返回：0=覆盖，1=跳过，2=用户取消（调用方应对 2 执行 exit）
should_overwrite() {
  local target="$1"
  [[ "${CFG[dry_run]}" == '1' ]] && return 0
  [[ "${CFG[force]}"   == '1' ]] && return 0
  case "$_CONFLICT_MODE" in
    overwrite_all) return 0 ;;
    skip_all)      return 1 ;;
  esac
  # 非交互环境默认覆盖
  [[ ! -t 0 ]] && return 0

  log "目标已存在：$target"
  printf '1) 覆盖 / 2) 跳过 / 3) 全部覆盖 / 4) 全部跳过 [默认 1，Esc 退出]：' >&2
  local key='' key2=''
  IFS= read -rsn1 key || { log "已取消"; return 2; }

  # lone ESC：超时内无后续字节则为单独 Esc；否则视为终端转义序列，按无效处理
  if [[ "$key" == $'\e' ]]; then
    if IFS= read -rsn1 -t 0.05 key2 2>/dev/null; then
      log "无效选择，默认覆盖"; return 0
    fi
    log "已取消（Esc）" >&2
    return 2
  fi

  case "$key" in
    $'\n'|$'\r') return 0 ;;
    1)           return 0 ;;
    2)           return 1 ;;
    3) _CONFLICT_MODE='overwrite_all'; return 0 ;;
    4) _CONFLICT_MODE='skip_all';      return 1 ;;
    *) log "无效选择，默认覆盖";       return 0 ;;
  esac
}

# 带冲突处理的单文件拷贝（内部公共实现）
# 用法：copy_with_conflict <src> <dst>
# 说明：dry-run / force / 交互策略均在此统一处理；调用方负责后续内容替换
copy_with_conflict() {
  local src="$1" dst="$2"
  if [[ "${CFG[dry_run]}" == '1' ]]; then
    log "[dry-run] 拷贝: $src → $dst"; return 0
  fi
  if [[ -e "$dst" ]]; then
    local _ow=0
    should_overwrite "$dst" || _ow=$?
    [[ "$_ow" -eq 2 ]] && exit 130
    [[ "$_ow" -eq 1 ]] && { log "[skip] $dst"; return 1; }  # 返回 1 表示已跳过
    backup_path "$dst"
  fi
  ensure_dir "$(dirname "$dst")"
  cp "$src" "$dst"
  return 0
}

# 拷贝单个文件（含冲突处理）
copy_file() {
  local src="$1" dst="$2"
  copy_with_conflict "$src" "$dst" || return 0  # skip 时静默返回
}

# 拷贝目录（含冲突处理）
copy_dir() {
  local src="$1" dst="$2"
  if [[ "${CFG[dry_run]}" == '1' ]]; then
    log "[dry-run] 拷贝目录: $src → $dst"; return 0
  fi
  if [[ -e "$dst" ]]; then
    local _ow=0
    should_overwrite "$dst" || _ow=$?
    [[ "$_ow" -eq 2 ]] && exit 130
    [[ "$_ow" -eq 1 ]] && { log "[skip] $dst"; return 0; }
    backup_path "$dst"
  fi
  ensure_dir "$(dirname "$dst")"
  ensure_dir "$dst"
  if have_cmd rsync; then
    rsync -a "$src"/ "$dst"/
  else
    cp -R "$src"/. "$dst"/
  fi
}

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
  for e in "${entries[@]}"; do backup_path "$e"; done
  ensure_dir "$docs_dir"
  info "DOC_DIR 已清空（目录保留）: $docs_dir"
}


# =============================================================================
# § 5  内容替换函数
# =============================================================================

# 将文档前缀统一归一为 ${DOC_DIR}/（保持幂等）
rewrite_docs_prefix_to_doc_dir() {
  local file="$1" docs_slash="$2"
  [[ -f "$file" ]] && sdx_is_text_file "$file" || return 0
  have_perl || return 0
  SDX_DOCS_SLASH="$docs_slash" \
    perl -CSD -i -pe '
      next if /\$\{DOC_DIR\}\//;
      if ($ENV{SDX_DOCS_SLASH} ne "./") {
        my $needle = quotemeta($ENV{SDX_DOCS_SLASH});
        s{$needle}{\${DOC_DIR}/}gi;
      }
      s{system/}{\${DOC_DIR}/}gi;
    ' "$file" 2>/dev/null || true
}

# 输出规则命中明细（行号 + 片段，片段最大 160 字符）
# 用法：log_rewrite_hits <level> <rule> <file> <pattern> [i]
#   第 5 个参数为 i 时按不区分大小写匹配
log_rewrite_hits() {
  local level="$1" rule="$2" file="$3" pattern="$4" ci="${5:-}"
  [[ -f "$file" && -n "$pattern" ]] || return 0
  have_perl || return 0

  # ci=i 时追加 /i 修饰符；统一用一段 perl，通过环境变量传递 case-insensitive 标志
  SDX_LOG_LEVEL="$level" SDX_LOG_RULE="$rule" SDX_LOG_FILE="$file" \
  SDX_LOG_PATTERN="$pattern" SDX_LOG_CI="${ci}" \
    perl -CSD -ne '
      my $pat = $ENV{SDX_LOG_PATTERN};
      my $ci  = $ENV{SDX_LOG_CI} eq "i";
      my $matched = $ci ? /$pat/i : /$pat/;
      if ($matched) {
        my $line = $_;
        chomp $line;
        $line = substr($line, 0, 160);
        print "$ENV{SDX_LOG_LEVEL} [$ENV{SDX_LOG_RULE}] file=$ENV{SDX_LOG_FILE} line=$. text=$line\n";
      }
    ' "$file" 2>/dev/null || true
}

# 在 DOC_ROOT/README.md 注入或更新「Agent 路径」说明（HTML 注释标记块，幂等）
# 用法：docs_install_inject_readme_agent_note <readme_path> <primary_dir> [other_dir ...]
docs_install_inject_readme_agent_note() {
  local readme="$1" primary="$2"
  shift 2
  local -a others=("$@")
  [[ -f "$readme" ]] || return 0
  have_perl || return 0

  local oline
  if (( ${#others[@]} > 0 )); then
    local oj
    oj=$(printf '%s、' "${others[@]}")
    oj="${oj%、}"
    oline="**其他可用 Agent 根目录**：${oj}（可通过 \`agent-install --agents=...\` 安装对应目录）。"
  else
    oline="**其他可用 Agent 根目录**：无（当前 \`AGENT_DIRS\` 仅含主目录）。"
  fi

  local note_tmp
  note_tmp="$(mktemp "${TMPDIR:-/tmp}/sdx-agent-readme-note.XXXXXX")" || return 0
  {
    printf '%s\n' '<!-- sdx-agent-dirs-note:begin -->'
    printf '%s\n' "> **Agent 路径**：知识库内指向中央库 **agent** 树的路径已重写为当前主目录 \`${primary}/\`（与 \`.docsconfig\` 的 \`AGENT_DIRS\` 首项一致）。"
    printf '%s\n' "> ${oline}"
    printf '%s\n' '<!-- sdx-agent-dirs-note:end -->'
  } > "$note_tmp"

  SDX_NOTE_FILE="$note_tmp" perl -CSD -e '
    use strict;
    use warnings;
    use utf8;
    my $path = $ARGV[0];
    open my $fh, "<:encoding(UTF-8)", $path or exit 0;
    local $/;
    my $t = <$fh>;
    close $fh;
    open my $nf, "<:encoding(UTF-8)", $ENV{SDX_NOTE_FILE} or exit 0;
    my $nb = <$nf>;
    close $nf;
    chomp $nb;
    my $b = "<!-- sdx-agent-dirs-note:begin -->";
    my $e = "<!-- sdx-agent-dirs-note:end -->";
    if ($t =~ /\Q$b\E/s && $t =~ /\Q$e\E/s) {
      $t =~ s{\Q$b\E[\s\S]*?\Q$e\E}{$nb}s;
    } else {
      $t .= "\n\n" . $nb . "\n";
    }
    open $fh, ">:encoding(UTF-8)", $path or exit 0;
    print $fh $t;
    close $fh;
  ' "$readme" 2>/dev/null || true
  rm -f "$note_tmp"
}

# 知识库安装并写入 .docsconfig 后：按 AGENT_DIRS 首项将 agent/ 重写为主 Agent 目录，并更新 README 提示
rewrite_knowledge_agent_paths_after_install() {
  [[ "${CFG[dry_run]}" == '1' ]] && return 0
  [[ "${CFG[scope]}" == 'knowledge' ]] || return 0
  [[ -n "${CFG[docs_abs]:-}" ]] || return 0

  local repo_target='' doc_root='' dd=''
  install_doc_path repo_target doc_root dd

  local cfg="$repo_target/.docsconfig"
  [[ -f "$cfg" ]] || { warn "未找到 $cfg，跳过 agent/ 路径重写"; return 0; }

  local _d _r _dd _ar ads _kt
  docsconfig_read_into "$cfg" _d _r _dd _ar ads _kt || true

  if [[ -z "${ads:-}" ]]; then
    ads='.cursor'
    info "AGENT_DIRS 为空，agent/ 路径重写默认使用首项: $ads"
  fi

  read -ra ads_arr <<< "$ads"
  local primary="${ads_arr[0]:-.cursor}"
  local -a others=()
  local i
  for (( i=1; i<${#ads_arr[@]}; i++ )); do
    others+=("${ads_arr[i]}")
  done

  local primary_slash="${primary%/}/"
  info ">>> 重写知识库中的 agent/ 路径段为 ${primary_slash}（AGENT_DIRS 首项）"
  sdx_rewrite_agent_path_segment_in_tree "${CFG[docs_abs]}" "$primary_slash"

  local readme="${CFG[docs_abs]}/README.md"
  if [[ -f "$readme" ]]; then
    docs_install_inject_readme_agent_note "$readme" "$primary" "${others[@]}"
  fi
}

# =============================================================================
# § 6  核心安装步骤
# =============================================================================

# 将单个文件从 application/ 树复制到目标文档根，并执行内容替换
# 用法：application_copy_one <src_f> <dst_f>
application_copy_one() {
  local src_f="$1" dst_f="$2"
  if [[ "${CFG[dry_run]}" == '1' ]]; then
    log "[dry-run] $src_f → $dst_f"
    return 0
  fi
  copy_with_conflict "$src_f" "$dst_f" || return 0  # skip 时静默返回
}

# 步骤 1a：application/ 全量 → 目标（standalone 或默认）
install_application_full_to_docs() {
  local src_root="${CFG[repo_root]}/application"
  local dst_root="${CFG[docs_abs]}"
  local docs_slash="${CFG[docs_slash]}"

  [[ -d "$src_root" ]] || error "未找到 application 目录: $src_root"
  info ">>> 初始化 application/（全量）→ 目标文档目录"
  info "    源:   $src_root"
  info "    目标: $dst_root"

    local rel src_f dst_f
    while IFS= read -r -d '' rel; do
      rel="${rel#./}"
      [[ -z "$rel" ]] && continue
      # 仅排除 application/ 根部的元文件与多版本 README（子目录 README.md 须照常同步）
      [[ "$rel" == 'DESIGN.md' || "$rel" == 'CONTRIBUTING.md' ]] && continue
      [[ "$rel" == 'README.md' || "$rel" == 'README-s.md' || "$rel" == 'README-c.md' ]] && continue

    src_f="$src_root/$rel"
    dst_f="$dst_root/$rel"
    application_copy_one "$src_f" "$dst_f"
  done < <(cd "$src_root" && find . -type f -print0)

  # standalone 使用 README-s.md 作为目标 README.md；缺失则回退 README.md
  local readme_src="$src_root/README-s.md"
  [[ -f "$readme_src" ]] || readme_src="$src_root/README.md"
  [[ -f "$readme_src" ]] && application_copy_one "$readme_src" "$dst_root/README.md"

  info "    application/ 全量同步完成"
}

# 步骤 1b：application/ §2.1 核心子集（central + type=application）
install_application_subset_to_docs() {
  local src_root="${CFG[repo_root]}/application"
  local dst_root="${CFG[docs_abs]}"
  local docs_slash="${CFG[docs_slash]}"

  [[ -d "$src_root" ]] || error "未找到 application 目录: $src_root"
  info ">>> 初始化 application/（§2.1 核心子集，central + type=application）→ 目标"
  info "    源:   $src_root"
  info "    目标: $dst_root"

  local d rel src_f dst_f
  for d in changelogs knowledge specs; do
    [[ -d "$src_root/$d" ]] || { warn "§2.1 子集：跳过缺失目录 application/$d"; continue; }
    while IFS= read -r -d '' rel; do
      rel="${rel#./}"
      [[ -z "$rel" ]] && continue
      src_f="$src_root/$d/$rel"
      dst_f="$dst_root/$d/$rel"
      application_copy_one "$src_f" "$dst_f"
    done < <(cd "$src_root/$d" && find . -type f -print0)
  done

  local base
  for base in INDEX_GUIDE.md docs_meta.yaml manifest.yaml; do
    [[ -f "$src_root/$base" ]] || continue
    application_copy_one "$src_root/$base" "$dst_root/$base"
  done

  # central 使用 README-c.md 作为目标 README.md；缺失则回退 README.md
  local readme_src="$src_root/README-c.md"
  [[ -f "$readme_src" ]] || readme_src="$src_root/README.md"
  [[ -f "$readme_src" ]] && application_copy_one "$readme_src" "$dst_root/README.md"

  info "    application/ §2.1 子集同步完成"
}

# 步骤 1c：仓库顶层 system/ 或 company/ → 目标（组织级 / 公司级知识库根）
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

    if [[ "${CFG[dry_run]}" == '1' ]]; then
      log "[dry-run] $src_f → $dst_f"; continue
    fi
    # 复用统一冲突处理；跳过时 continue
    copy_with_conflict "$src_f" "$dst_f" || continue
  done < <(cd "$src_root" && find . -type f -print0)

  info "    ${label}/ 同步完成"
}

# 步骤 1d：type=system|company 时，将 docs-link.sh / link-config.sh 安装至目标工程根 scripts/
install_docs_link_scripts_to_target_repo() {
  case "${CFG[type]}" in
    system|company) ;;
    *) return 0 ;;
  esac
  local dst_dir="${CFG[target_dir]}/scripts"
  info ">>> 安装建联脚本至目标工程: ${dst_dir}（docs-link.sh、link-config.sh）"
  ensure_dir "$dst_dir"
  copy_file "${CFG[repo_root]}/scripts/docs-link.sh" "$dst_dir/docs-link.sh"
  copy_file "${CFG[repo_root]}/scripts/link-config.sh" "$dst_dir/link-config.sh"
}

# 步骤 1 分发：按 type × mode 将知识库模板安装至目标文档目录
install_docs() {
  case "${CFG[type]}" in
    application)
      if [[ "${CFG[mode]}" == 'central' ]]; then
        install_application_subset_to_docs
      else
        install_application_full_to_docs
      fi
      ;;
    system)  install_org_template_to_docs 'system'  "${CFG[repo_root]}/system"  ;;
    company) install_org_template_to_docs 'company' "${CFG[repo_root]}/company" ;;
    *)       error "内部错误：未知 type=${CFG[type]}" ;;
  esac
}

# =============================================================================
# § 8  .docsconfig 写入
# =============================================================================

# 推导 .docsconfig 所需的 repo_target / doc_root / dd（DOC_DIR）三元组
# 用法：resolve_docsconfig_roots <nameref_repo_target> <nameref_doc_root> <nameref_dd>
# 说明：
#   - 有 docs_abs：从 docs_abs 推导 repo_target 与 dd
#   - 无 docs_abs：回退到 HOME（仅 config/knowledge scope 时调用）
resolve_docsconfig_roots() {
  local -n _rt="${1:?}"   # repo_target（输出）
  local -n _dr="${2:?}"   # doc_root（输出）
  local -n _dd="${3:?}"   # doc_dir（输出）

  if [[ -n "${CFG[docs_abs]}" ]]; then
    _dr="${CFG[docs_abs]}"
    _rt="$(docsconfig_repo_root_from_doc_root "$_dr")"
    if [[ -z "$_rt" ]]; then
      _rt="$(docsconfig_repo_root_fallback_from_doc_root "$_dr")"
      [[ -n "$_rt" ]] \
        || error "无法写入 .docsconfig：DOC_ROOT 父目录不可解析: $_dr"
      warn "未检测到 DOC_ROOT 所在 Git 仓库，已回退使用父目录作为 REPO_ROOT: $_rt"
    fi
    _dd="$(docsconfig_doc_dir_from_roots "$_rt" "$_dr")" \
      || error "无法计算 DOC_DIR（DOC_ROOT 须位于 REPO_ROOT 目录下）"
  else
    [[ -n "${CFG[home_abs]}" ]] || error "无法写入 .docsconfig：HOME 未就绪"
    _dr="${CFG[home_abs]}"
    _rt="${CFG[home_abs]}"
    _dd='.'
  fi
}

# 计算 docsconfig 写入所需 DOC_* 路径
# 用法：install_doc_path <nameref_repo_target> <nameref_doc_root> <nameref_dd>
install_doc_path() {
  resolve_docsconfig_roots "${1:?}" "${2:?}" "${3:?}"
}

# 计算 docsconfig 写入所需 KNOWLEDGE_TYPE
# 用法：install_knowledge_type <nameref_kt_out>
install_knowledge_type() {
  local -n _kt="${1:?}"   # knowledge_type（输出）

  case "${CFG[scope]}" in
    knowledge) _kt="${CFG[type]}" ;;
    config) _kt='' ;;
  esac
}

# 计算 docsconfig 写入所需 AGENT_*
# 用法：install_agent_path <nameref_agent_root_out> <nameref_agent_dirs_out> <old_agent_root> <old_agent_dirs>
install_agent_path() {
  local -n _ar_out="${1:?}"  # agent_root（输出）
  local -n _ads_out="${2:?}" # agent_dirs（输出）
  local old_agent_root="${3:-}"
  local old_agent_dirs="${4:-}"

  _ar_out=''
  _ads_out=''

  [[ -n "${CFG[home_abs]:-}" ]] || error "无法补全 AGENT_*：HOME 未就绪"

  if [[ -n "${old_agent_root:-}" ]]; then
    _ar_out="$old_agent_root"
    _ads_out="${old_agent_dirs:-}"
    return 0
  fi

  _ar_out="$(strip_trailing_slash "$(abs_path "${CFG[home_abs]}")")"
  _ads_out='.cursor'
  info "未配置 AGENT_ROOT 或配置为空，已写入默认: ${_ar_out}（AGENT_DIRS=\"${_ads_out}\"）"
}

# 写入目标工程仓库根 .docsconfig（DOC_*、KNOWLEDGE_TYPE；scope=config|knowledge 均按需补全 AGENT_*）
# dry-run 时仅预览，不写入
install_docsconfig() {
  local doc_root='' repo_target='' dd=''
  local old_doc_root='' old_repo_root='' old_doc_dir=''
  local old_agent_root='' old_agent_dirs=''
  local old_knowledge_type=''
  local cfg_file existed=0
  local kt_out=''
  local ar_out='' ads_out=''
  install_doc_path repo_target doc_root dd

  # ── 读取已有 .docsconfig（若存在）────────────────────────────────────────
  cfg_file="$repo_target/.docsconfig"
  if [[ -f "$cfg_file" ]]; then
    existed=1
    docsconfig_read_into "$cfg_file" old_doc_root old_repo_root old_doc_dir \
      old_agent_root old_agent_dirs old_knowledge_type || true
  fi

  if [[ "$existed" == '1' ]]; then
    info ".docsconfig 已存在，将按当前路径重算并覆盖写入: $cfg_file"
  else
    info ".docsconfig 不存在，将创建并写入: $cfg_file"
  fi

  install_knowledge_type kt_out
  if [[ "${CFG[scope]}" == 'config' || "${CFG[scope]}" == 'knowledge' ]]; then
    install_agent_path ar_out ads_out "$old_agent_root" "$old_agent_dirs"
  fi

  # ── 写入 ──────────────────────────────────────────────────────────────────
  if [[ -n "$ar_out" ]]; then
    docsconfig_write "$repo_target" "$doc_root" "$dd" "${CFG[dry_run]}" \
      "$ar_out" "$ads_out" "${kt_out:-}"
  else
    docsconfig_write "$repo_target" "$doc_root" "$dd" "${CFG[dry_run]}" "${kt_out:-}"
  fi
}


# =============================================================================
# § 9  CLI：usage / parse_args
# =============================================================================

usage() {
  cat >&2 <<'EOF'
用法
  docs-install.sh [选项] --target=<目标工程文档目录>

说明
  --target：目标工程文档目录（必填）。例如：
    ~/workspace/my-app/docs
    ~/workspace/my-app/system
    
  --scope：同步范围
    knowledge|k（默认） 从本仓库按 --type 同步 knowledge 目录到 --target，并写入 .docsconfig（含 KNOWLEDGE_TYPE）
    config|c           仅在目标工程仓库根写入/更新 .docsconfig（仅路径键与 AGENT_*，不同步 knowledge）
  
  --type：知识库类型，仅在 scope=knowledge 时有效
    application|a（默认）  应用知识库：standalone 全量；central §2.1 子集
    system|s             仓库顶层 system/ → 目标（全量；mode 固定 standalone）
    company|c            仓库顶层 company/ → 目标（全量；mode 固定 standalone）

  --mode：模式，仅在 scope=knowledge 时有效
    standalone|s（默认）  仅目标工程落盘
    central|c            仅当 type=application 时有效（application 子集分发）
  
选项
  --target=PATH   目标工程文档目录（必填）
  --scope=SCOPE   knowledge(k) | config(c)  [默认: k]
                  k|knowledge  同步知识库并写 .docsconfig（含 KNOWLEDGE_TYPE）
                  config       仅写 .docsconfig（不写 KNOWLEDGE_TYPE）
  --type=TYPE     application(a) | system(s) | company(c)  [默认: a]
  --mode=MODE     standalone(s) | central(c)  [默认: s]
  -r              允许工程根目录不存在时自动创建
  --force         强制覆盖，不提示
  --dry-run       预览模式，不写入任何文件
  -h, --help      显示此帮助

环境变量
  REPO_ROOT             本仓库（中央库）根目录（默认自动探测）
  HOME                  用户主目录
  CREATE_PROJECT_ROOT   1=允许自动创建工程根（等同 -r）
  SCOPE                 未传 --scope 时的默认值
  FORCE                 1=强制覆盖

示例
  ./scripts/docs-install.sh --target=~/workspace/my-app/docs
  ./scripts/docs-install.sh --scope=knowledge --target=~/workspace/my-app/docs
  ./scripts/docs-install.sh --scope=config --target=~/workspace/my-app/docs
  ./scripts/docs-install.sh --mode=central --type=application --target=~/workspace/my-app/docs
  ./scripts/docs-install.sh --mode=standalone --type=system --target=~/workspace/my-app/system
  ./scripts/docs-install.sh --dry-run --target=~/workspace/my-app/docs
EOF
}

parse_args() {
  while (( $# > 0 )); do
    case "$1" in
      --target=*) CFG[target_opt]="${1#*=}";                  shift ;;
      --mode=*)   CFG[mode]="${1#*=}";                        shift ;;
      --mode)     shift; CFG[mode]="${1:-}";                  shift ;;
      --scope=*)  CFG[scope]="${1#*=}";                       shift ;;
      --scope)    shift; CFG[scope]="${1:-}";                 shift ;;
      --type=*)   CFG[type]="${1#*=}"; CFG[type_explicit]=1;  shift ;;
      --type)     shift; CFG[type]="${1:-}"; CFG[type_explicit]=1; shift ;;
      --dry-run)  CFG[dry_run]=1;                             shift ;;
      --force)    CFG[force]=1;                               shift ;;
      -r)         CFG[create_project_root]=1;                 shift ;;
      -h|--help)  usage; exit 0 ;;
      *)
        error "未知参数: $1（使用 -h 或 --help 查看帮助）"
        ;;
    esac
  done

  [[ -n "${CFG[target_opt]}" ]] \
    || error "缺少必填参数 --target=<目标工程文档目录>"
  CFG[docs_abs]="${CFG[target_opt]}"
}


# =============================================================================
# § 10  初始化与校验
# =============================================================================

# 初始化并校验 REPO_ROOT
init_repo_root() {
  if [[ -z "${CFG[repo_root]}" ]]; then
    CFG[repo_root]="$(abs_path "$SCRIPT_DIR/..")"
  fi
  [[ -d "${CFG[repo_root]}/application"    ]] || error "未找到 application 目录: ${CFG[repo_root]}/application"
}

# 校验并规范化文档目录与工程根目录
validate_docs_and_target() {
  [[ -n "${CFG[docs_abs]}" ]] \
    || error "内部错误：应在提供 <目标工程文档目录> 后调用文档路径校验"

  CFG[docs_abs]="$(strip_trailing_slash "$(abs_path "${CFG[docs_abs]}")")"
  CFG[target_dir]="$(abs_path "$(dirname "${CFG[docs_abs]}")")"

  local target_dir="${CFG[target_dir]}"
  if [[ -e "$target_dir" && ! -d "$target_dir" ]]; then
    error "工程根已存在但不是目录: $target_dir"
  fi
  if [[ ! -d "$target_dir" ]]; then
    if [[ "${CFG[create_project_root]}" == '1' ]]; then
      run_or_dry mkdir -p "$target_dir"
      [[ "${CFG[dry_run]}" == '0' ]] && info "已创建工程根目录: $target_dir"
    else
      error "工程根目录不存在: ${target_dir}（请先创建，或使用 -r 自动创建）"
    fi
  fi
  # DOC_ROOT 须为已存在目录，否则 .docsconfig 推导失败
  if [[ ! -d "${CFG[docs_abs]}" ]]; then
    run_or_dry mkdir -p "${CFG[docs_abs]}"
  fi
}

# 规范化并校验 --mode
apply_mode() {
  CFG[mode]="$(normalize_mode "${CFG[mode]}")"
  validate_mode "${CFG[mode]}" || error "无效模式: ${CFG[mode]}（standalone/central 或 s/c）"
}

# 规范化并校验 --scope
validate_sync_scope() {
  [[ "${CFG[scope]}" != 'ck' ]] \
    || error "无效 --scope: ck（已移除，请使用 --scope=k 或 --scope=knowledge）"
  validate_scope "${CFG[scope]}" \
    || error "无效 --scope: ${CFG[scope]}（支持 knowledge/k、config/c）"
  CFG[scope]="$(normalize_scope "${CFG[scope]}")"
}

# --scope=config|knowledge 时必须提供 --target
validate_docs_arg_for_scope() {
  case "${CFG[scope]}" in
    config|knowledge)
      [[ -n "${CFG[docs_abs]:-}" ]] \
        || error "--scope=${CFG[scope]} 时必须指定 --target=<目标工程文档目录>"
      ;;
  esac
}

# 文档约定：--mode=central 仅在 scope=knowledge 时参与知识库分发
apply_mode_scope_policy() {
  case "${CFG[scope]}" in
    knowledge) ;;
    *)
      if [[ "${CFG[mode]}" == 'central' ]]; then
        warn "提示：--mode=central 仅在 scope=knowledge 时生效；当前 scope=${CFG[scope]}，已按 standalone 处理"
        CFG[mode]='standalone'
      fi
      ;;
  esac
}

# 文档约定：--type 仅在 scope=knowledge 时生效（与 install_docs 选型相关）
apply_type_scope_policy() {
  case "${CFG[scope]}" in
    knowledge) ;;
    *)
      if [[ "${CFG[type_explicit]}" == '1' ]]; then
        warn "提示：--type 仅在 scope=knowledge 时生效；已忽略"
        CFG[type_explicit]=0
      fi
      ;;
  esac
}

# 解析 --type（未显式指定时默认 application）
resolve_type() {
  if [[ "${CFG[type_explicit]}" == '1' ]]; then
    CFG[type]="$(normalize_type "${CFG[type]}")"
    validate_type "${CFG[type]}" \
      || error "无效 --type: ${CFG[type]}（application(a)|system(s)|company(c)）"
  else
    CFG[type]='application'
  fi

}

# 约束：mode 仅对 type=application 生效
validate_mode_type_policy() {
  [[ "${CFG[scope]}" == 'knowledge' ]] || return 0
  [[ "${CFG[mode]}" == 'central' ]] || return 0

  case "${CFG[type]}" in
    application) ;;
    system|company) error "--mode=central 仅支持 --type=application（当前：${CFG[type]}）" ;;
    *) error "内部错误：未知 type=${CFG[type]}" ;;
  esac
}

# 校验 --type 对应的源目录存在
validate_type_sources() {
  case "${CFG[type]}" in
    application) [[ -d "${CFG[repo_root]}/application" ]] || error "未找到 application/: ${CFG[repo_root]}/application" ;;
    system)      [[ -d "${CFG[repo_root]}/system"      ]] || error "未找到 system/: ${CFG[repo_root]}/system（type=system）" ;;
    company)     [[ -d "${CFG[repo_root]}/company"     ]] || error "未找到 company/: ${CFG[repo_root]}/company（type=company）" ;;
  esac
}

# 计算运行时派生路径（docs_slash）
compute_derived_paths() {
  if [[ -n "${CFG[docs_abs]}" ]]; then
    CFG[docs_slash]="$(compute_docs_rel_slash "${CFG[target_dir]}" "${CFG[docs_abs]}")"
  else
    # 未传文档目录时采用约定默认值
    CFG[docs_slash]='docs/'
  fi
}

# =============================================================================
# § 11  完成提示
# =============================================================================

print_checklist() {
  log ''
  log '─────────────────────────────────────────────────────────────────────────'
  log "初始化完成  目标: ${CFG[docs_abs]}"
  log '─────────────────────────────────────────────────────────────────────────'
  post_init_checklist "${CFG[docs_abs]}" >&2
}

# =============================================================================
# § 12  主入口（parse_args 之后的主体）
# =============================================================================

docs_init_run() {
  init_repo_root
  validate_sync_scope
  validate_docs_arg_for_scope
  apply_type_scope_policy
  resolve_type
  apply_mode
  apply_mode_scope_policy
  validate_mode_type_policy

  validate_type_sources

  # ── scope=config：仅 install_docsconfig，后退出 ─────────────────────────
  if [[ "${CFG[scope]}" == 'config' ]]; then
    [[ -n "${HOME:-}" ]] || error "需要 HOME 环境变量"
    CFG[home_abs]="$(abs_path "$HOME")"
    validate_docs_and_target
    install_docsconfig
    info "完成：docs-install（--scope=config）"
    print_checklist
    exit 0
  fi

  validate_docs_and_target

  compute_derived_paths
  DOC_INIT_STAMP="$(date +%Y-%m-%d_%H-%M-%S)"

  [[ -n "${HOME:-}" ]] || error "需要 HOME 环境变量"
  CFG[home_abs]="$(abs_path "$HOME")"

  have_perl || warn "未检测到 perl：文件内容替换将被跳过，建议安装 perl。"

  # ── 步骤 1：知识库同步 ────────────────────────────────────────────────────
  if should_reset_docs_dir_before_sync; then
    reset_docs_dir_with_backup
  fi

  if [[ -n "${CFG[docs_abs]}" && "${CFG[scope]}" == 'knowledge' ]]; then
    install_docs
    install_docs_link_scripts_to_target_repo
    install_docsconfig
    rewrite_knowledge_agent_paths_after_install
  fi

  # ── 步骤 2：scope=knowledge 写 .docsconfig（含 KNOWLEDGE_TYPE）──────────────

  info "完成：初始化"
  print_checklist
}

# ========== 入口（默认 --scope=k，即 knowledge）==========
if [[ "$#" -eq 0 ]]; then
  parse_args --scope="${KINIT_DEFAULT_SCOPE:-k}"
else
  parse_args "$@"
fi

docs_init_run
