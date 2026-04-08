#!/usr/bin/env bash
# docs-init：按 --type×--mode 从本仓库 application/、system/、company/ 同步到目标工程文档目录；
# 按 --scope 选择知识库同步、.docsconfig、Agent skills/rules 及（可选）central 登记（默认 scope=ck）。
#
# 功能摘要（与 usage 一致）：
#   - 来源与替换：由 --type 决定拷贝哪棵模板树；模板内 system/、文件名与字面量替换见 rewrite_doc_file*
#   - --mode：standalone 仅目标落盘；central 另在本仓库（源知识库）登记目标工程（常配合 type=application）
#   - --scope：ck（默认）= 同步知识库 + 文末写目标 .docsconfig；config = 仅登记 .docsconfig（可 central 后退出）；
#     knowledge = 仅同步知识库；skills / rules / rs = 仅 Agent；all = 知识库 + .docsconfig + skills/rules
#   - Agent：.agent/skills、.agent/rules → 未传文档目录时装到 ~/.cursor 等；传入 <目标工程文档目录> 时装到 <工程根>/.cursor 等
#   - central + type=application：登记 application/INDEX_GUIDE.md「十」+ system/application-<slug>/ 槽位；不要求目标 DOC_ROOT 下已有 knowledge/
#
# 步骤（主流程）：
#   0. --scope=config：write_target_docsconfig（+ 可选 install_central）后退出
#   1. 模板 → 目标文档目录（install_system_to_docs；scope 为 all / knowledge / ck 时）
#      - type=application：standalone 全量 application/；central 仅 §2.1 子集
#      - type=system|company：同步仓库顶层 system/ 或 company/
#   2. central + type=application：install_central（登记 + 联邦槽位）
#   3. scope 含 skills/rules/rs/all：install_agent_skills / install_agent_rules
#   4. 已提供文档目录：write_target_docsconfig（config 早退路径已在步骤 0）
#
# 运行要求：Bash 5+；内容替换依赖 perl（UTF-8）

set -euo pipefail

# ─── 引导 ────────────────────────────────────────────────────────────────────

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$SCRIPT_DIR/docs-config.sh" ]] \
  || { printf '错误: 缺少配置文件 %s\n' "$SCRIPT_DIR/docs-config.sh" >&2; exit 1; }

# shellcheck disable=SC1091
source "$SCRIPT_DIR/docs-config.sh"

# ─── 日志 ────────────────────────────────────────────────────────────────────

log()   { printf '%s\n'      "$*"        >&2; }
info()  { printf '信息: %s\n' "$*"        >&2; }
warn()  { printf '警告: %s\n' "$*"        >&2; }
error() { printf '错误: %s\n' "$*" >&2; exit 1; }

# ─── 全局配置（关联数组，单一事实源）────────────────────────────────────────

declare -A CFG=(
  [repo_root]="${REPO_ROOT:-}"
  [docs_abs]=""
  [target_dir]=""
  [mode]="${MODE:-standalone}"
  [type]="${TYPE:-}"
  [type_explicit]=0
  [scope]="${SCOPE:-ck}"
  [agents_opt]="${AGENTS_OPT:-cursor}"
  [app_id_opt]="${APP_ID_OPT:-}"
  [dry_run]="${DRY_RUN:-0}"
  [force]="${FORCE:-0}"
  [create_project_root]="${CREATE_PROJECT_ROOT:-0}"
  # 运行时填充
  [primary_agent_slash]=""
  [docs_slash]=""
  [central_app_id]=""
  [central_app_slug]=""
  [home_abs]=""
)

declare -a ENABLED_AGENTS=()

# 冲突处理模式（交互状态，不放入 CFG 避免混淆）
_CONFLICT_MODE="${CONFLICT_PROMPT_MODE:-}"
_BACKUP_ROOT="${BACKUP_ROOT:-}"
_BACKUP_ROOT_AGENT="${BACKUP_ROOT_AGENT:-}"
# 单次运行共用时间戳（工程侧与 $HOME 侧 .docs-init 备份一致）
DOC_INIT_STAMP=""


# ─── 工具函数（纯函数，无副作用）────────────────────────────────────────────

have_cmd()  { command -v "$1" >/dev/null 2>&1; }
have_perl() { have_cmd perl; }

# 判断是否为文本文件（按扩展名或 MIME）
is_text_file() {
  local f="$1"
  case "$f" in
    *.md|*.yaml|*.yml|*.json|*.jsonl|*.txt|*.sh|*.gitignore|*.html|*.css|*.js|*.toml)
      return 0 ;;
  esac
  if have_cmd file; then
    local mt
    mt="$(file -b --mime-type "$f" 2>/dev/null || true)"
    [[ "$mt" == text/* || "$mt" == application/json || "$mt" == *yaml* || "$mt" == *json* ]] && return 0
  fi
  return 1
}

# 路径各段文件名中的 system（不区分大小写）→ application
map_path_system_to_application() {
  local rel="${1#./}"
  [[ -z "$rel" ]] && { printf ''; return 0; }
  local IFS='/'
  local -a parts
  read -ra parts <<< "$rel"
  local out="" sep="" p newp
  for p in "${parts[@]}"; do
    [[ -z "$p" ]] && continue
    newp="$(perl -CSD -pe 's/SYSTEM_INDEX/INDEX_GUIDE/gi; s/APPLICATION_INDEX/INDEX_GUIDE/gi; s/system/application/gi' <<< "$p")"
    out="${out}${sep}${newp}"
    sep="/"
  done
  printf '%s' "$out"
}

# 计算目标工程根相对文档目录路径（带尾斜杠）
# 用于将模板中字面量 system/ 替换为实际文档前缀
compute_docs_rel_slash() {
  local root docs
  root="$(strip_trailing_slash "$1")"
  docs="$(strip_trailing_slash "$2")"
  if   [[ "$docs" == "$root"   ]]; then printf './\n'
  elif [[ "$docs" == "$root"/* ]]; then printf '%s/\n' "${docs#"$root"/}"
  else                                   printf '%s/\n' "$docs"
  fi
}

# 探测目标目录所在 Git 仓库的 remote.origin.url 或本地根路径
git_repo_ref() {
  local target="$1"
  have_cmd git || { printf ''; return 0; }
  git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1 || { printf ''; return 0; }
  local url
  url="$(git -C "$target" config --get remote.origin.url 2>/dev/null || true)"
  if [[ -n "$url" ]]; then printf '%s' "$url"; return 0; fi
  local root
  root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -n "$root" ]] && printf '%s' "$(abs_path "$root")" || printf ''
}

# 探测目标目录所在 Git 仓库根路径
git_root_path() {
  local target="$1"
  have_cmd git || { printf ''; return 0; }
  git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1 || { printf ''; return 0; }
  local root
  root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -n "$root" ]] && printf '%s' "$(abs_path "$root")" || printf ''
}

# 返回 docs_abs 相对于 git_root 的路径（或绝对路径）
docs_rel_to_git_root() {
  local git_root docs_abs
  git_root="$(strip_trailing_slash "$1")"
  docs_abs="$(strip_trailing_slash "$2")"
  [[ -z "$git_root" ]] && { printf '%s' "$docs_abs"; return 0; }
  case "$docs_abs" in
    "$git_root")   printf '/' ;;
    "$git_root"/*) printf '%s' "${docs_abs#"$git_root"}" ;;
    *)             printf '%s' "$docs_abs" ;;
  esac
}


# ─── 副作用工具（IO 操作）────────────────────────────────────────────────────

# dry-run 感知的命令执行器：dry=1 时只打印，否则执行
run_or_dry() {
  if [[ "${CFG[dry_run]}" == "1" ]]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

ensure_dir() {
  run_or_dry mkdir -p "$1"
}

# 本次运行是否应在同步前重置 DOC_DIR（仅知识库同步）
should_reset_docs_dir_before_sync() {
  [[ -n "${CFG[docs_abs]:-}" ]] || return 1
  case "${CFG[scope]}" in
    all|knowledge|ck) return 0 ;;
    *)                return 1 ;;
  esac
}

# 备份并清空 DOC_DIR（保留目录本身）
reset_docs_dir_with_backup() {
  local docs_dir="${CFG[docs_abs]}"
  local -a entries=()
  local p

  [[ -n "$docs_dir" && "$docs_dir" != "/" ]] || error "拒绝清空非法 DOC_DIR: ${docs_dir:-<empty>}"

  if [[ ! -d "$docs_dir" ]]; then
    info "DOC_DIR 不存在，创建空目录后继续: $docs_dir"
    ensure_dir "$docs_dir"
    return 0
  fi

  while IFS= read -r -d '' p; do
    entries+=("$p")
  done < <(find "$docs_dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null || true)

  if (( ${#entries[@]} == 0 )); then
    info "DOC_DIR 已为空，无需清理: $docs_dir"
    return 0
  fi

  info ">>> 知识库同步前备份并清空 DOC_DIR: $docs_dir"

  if [[ "${CFG[dry_run]}" == "1" ]]; then
    local e
    for e in "${entries[@]}"; do
      log "[dry-run] 备份并移出: $e -> $(get_backup_root)/..."
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

# 本次运行是否需要安装 Agent skills/rules
needs_agent_install() {
  case "${CFG[scope]}" in
    all|skills|rules|rs) return 0 ;;
    *)                     return 1 ;;
  esac
}

# Agent skills/rules 安装根：未指定文档目录 → ~/.cursor；指定文档目录 → <工程根>/.cursor（工程根 = 文档目录父目录）
agent_install_root() {
  local agent="$1"
  local rel
  rel="$(get_agent_dir "$agent")"
  if [[ -n "${CFG[docs_abs]:-}" ]]; then
    abs_path "${CFG[target_dir]}/$rel"
  else
    abs_path "${CFG[home_abs]}/$rel"
  fi
}

# 判断绝对路径是否落在用户主目录下的 Agent 安装树（.cursor / .trea / .claude）
path_is_under_agent_home() {
  local p="$1" home="${CFG[home_abs]:-}"
  [[ -z "$home" ]] && return 1
  p="$(abs_path "$p")"
  local d
  for d in .cursor .trea .claude; do
    [[ "$p" == "$home/$d" || "$p" == "$home/$d/"* ]] && return 0
  done
  return 1
}

# 获取（或初始化）本次运行的备份根目录（工程文档 / system 模板落盘）
get_backup_root() {
  if [[ -z "$_BACKUP_ROOT" ]]; then
    local stamp="${DOC_INIT_STAMP:-$(date +%Y-%m-%d_%H-%M-%S)}"
    _BACKUP_ROOT="${CFG[target_dir]:-$PWD}/.docs-init/${stamp}"
  fi
  printf '%s' "$_BACKUP_ROOT"
}

# 获取（或初始化）Agent 安装目录的备份根（~/.docs-init/<同一时间戳>/）
get_backup_root_agent() {
  if [[ -z "$_BACKUP_ROOT_AGENT" ]]; then
    local stamp="${DOC_INIT_STAMP:-$(date +%Y-%m-%d_%H-%M-%S)}"
    local home="${CFG[home_abs]:-}"
    [[ -n "$home" ]] || { printf '%s' ""; return 0; }
    _BACKUP_ROOT_AGENT="${home}/.docs-init/${stamp}"
  fi
  printf '%s' "$_BACKUP_ROOT_AGENT"
}

# 将已存在的路径备份到 .docs-init/<timestamp>/
backup_path() {
  local existing="$1"
  local backup_root rel backup_target
  existing="$(abs_path "$existing")"
  if path_is_under_agent_home "$existing"; then
    backup_root="$(get_backup_root_agent)"
    [[ -n "$backup_root" ]] || error "无法解析 Agent 备份根（缺少 HOME？）"
    rel="${existing#"${CFG[home_abs]}"/}"
  else
    backup_root="$(get_backup_root)"
    if [[ -n "${CFG[target_dir]}" && "$existing" == "${CFG[target_dir]}/"* ]]; then
      rel="${existing#"${CFG[target_dir]}"/}"
    else
      rel="${existing#/}"
    fi
  fi
  backup_target="${backup_root}/${rel}"
  # 避免同名冲突
  if [[ -e "$backup_target" ]]; then
    local i=1
    while [[ -e "${backup_target}.__${i}" ]]; do (( i++ )); done
    backup_target="${backup_target}.__${i}"
  fi
  mkdir -p "$(dirname "$backup_target")" 2>/dev/null || true
  mv "$existing" "$backup_target"
  info "已备份：$existing → $backup_target"
}

# 询问用户是否覆盖已存在目标（支持全局策略）
# 返回 0=覆盖，1=跳过，2=用户取消（Esc 等）——调用方应对 2 作 exit
should_overwrite() {
  local target="$1"
  [[ "${CFG[dry_run]}" == "1" ]] && return 0
  [[ "${CFG[force]}"   == "1" ]] && return 0
  case "$_CONFLICT_MODE" in
    overwrite_all) return 0 ;;
    skip_all)      return 1 ;;
  esac
  # 非交互环境默认覆盖
  [[ ! -t 0 ]] && return 0

  log "目标已存在：$target"
  printf '1) 覆盖 / 2) 跳过 / 3) 全部覆盖 / 4) 全部跳过 [默认 1，Esc 退出]：' >&2
  local key="" key2=""
  IFS= read -rsn1 key || { log "已取消"; return 2; }

  # 单独按 Esc：超时内无后续字节则为 lone ESC；否则视为终端转义序列，按无效处理
  if [[ "$key" == $'\e' ]]; then
    if IFS= read -rsn1 -t 0.05 key2 2>/dev/null; then
      log "无效选择，默认覆盖"; return 0
    fi
    log "已取消（Esc）" >&2
    return 2
  fi

  case "$key" in
    $'\n'|$'\r') return 0 ;;
    2) return 1 ;;
    3) _CONFLICT_MODE="overwrite_all"; return 0 ;;
    4) _CONFLICT_MODE="skip_all";      return 1 ;;
    1) return 0 ;;
    *) log "无效选择，默认覆盖"; return 0 ;;
  esac
}

# 拷贝单个文件（含冲突处理）
copy_file() {
  local src="$1" dst="$2"
  if [[ "${CFG[dry_run]}" == "1" ]]; then
    log "[dry-run] 拷贝文件: $src → $dst"; return 0
  fi
  if [[ -e "$dst" ]]; then
    local _ow=0
    should_overwrite "$dst" || _ow=$?
    [[ "$_ow" -eq 2 ]] && exit 130
    [[ "$_ow" -eq 1 ]] && { log "[skip] $dst"; return 0; }
    backup_path "$dst"
  fi
  ensure_dir "$(dirname "$dst")"
  cp "$src" "$dst"
}

# 拷贝目录（含冲突处理）
copy_dir() {
  local src="$1" dst="$2"
  if [[ "${CFG[dry_run]}" == "1" ]]; then
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


# ─── 内容替换 ─────────────────────────────────────────────────────────────────

# 将文档前缀统一归一为 ${DOC_DIR}/（保持幂等）
rewrite_docs_prefix_to_doc_dir() {
  local file="$1" docs_slash="$2"
  [[ -f "$file" ]] && is_text_file "$file" || return 0
  have_perl || return 0
  SDX_DOCS_SLASH="$docs_slash" \
    perl -CSD -i -pe '
      # 幂等保护：已是 ${DOC_DIR}/ 的路径不重复替换
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
# 说明：第 5 个参数为 i 时按不区分大小写匹配
log_rewrite_hits() {
  local level="$1" rule="$2" file="$3" pattern="$4" ci="${5:-}"
  [[ -f "$file" ]] || return 0
  have_perl || return 0
  [[ -n "$pattern" ]] || return 0

  if [[ "$ci" == "i" ]]; then
    SDX_LOG_LEVEL="$level" SDX_LOG_RULE="$rule" SDX_LOG_FILE="$file" SDX_LOG_PATTERN="$pattern" \
      perl -CSD -ne '
        my $pat = $ENV{SDX_LOG_PATTERN};
        if (/$pat/i) {
          my $line = $_;
          chomp $line;
          $line = substr($line, 0, 160);
          print "$ENV{SDX_LOG_LEVEL} [$ENV{SDX_LOG_RULE}] file=$ENV{SDX_LOG_FILE} line=$. text=$line\n";
        }
      ' "$file" 2>/dev/null || true
  else
    SDX_LOG_LEVEL="$level" SDX_LOG_RULE="$rule" SDX_LOG_FILE="$file" SDX_LOG_PATTERN="$pattern" \
      perl -CSD -ne '
        my $pat = $ENV{SDX_LOG_PATTERN};
        if (/$pat/) {
          my $line = $_;
          chomp $line;
          $line = substr($line, 0, 160);
          print "$ENV{SDX_LOG_LEVEL} [$ENV{SDX_LOG_RULE}] file=$ENV{SDX_LOG_FILE} line=$. text=$line\n";
        }
      ' "$file" 2>/dev/null || true
  fi
}

# 文档树替换：仅 .agent/ → agent_slash。
# 以下规则不执行，仅打印日志：system/→docs_slash、SYSTEM_INDEX/APPLICATION_INDEX→INDEX_GUIDE、
# system_meta/application_meta→docs_meta、词界 system→application（忽略大小写）、系统→应用。
rewrite_doc_file() {
  local file="$1" agent_slash="$2" docs_slash="$3"
  [[ -f "$file" ]] && is_text_file "$file" || return 0
  have_perl || { warn "未安装 perl，跳过内容替换：$file"; return 0; }
  SDX_AGENT_SLASH="$agent_slash" SDX_DOCS_SLASH="$docs_slash" \
    perl -CSD -i -pe '
      s{\.agent/}{$ENV{SDX_AGENT_SLASH}}g;
    ' "$file" 2>/dev/null || true
  info "rewrite_doc_file 已跳过规则: system/->docs_slash, SYSTEM_INDEX/APPLICATION_INDEX->INDEX_GUIDE, system_meta/application_meta->docs_meta, word-boundary system->application(case-insensitive), 系统->应用; file=${file}"
}

# Agent 树替换：仅处理 .agent/ → agent_slash
rewrite_agent_file() {
  local file="$1" agent_slash="$2" docs_slash="$3"
  [[ -f "$file" ]] && is_text_file "$file" || return 0
  have_perl || return 0
  SDX_AGENT_SLASH="$agent_slash" \
    perl -CSD -i -pe '
      s{\.agent/}{$ENV{SDX_AGENT_SLASH}}g;
    ' "$file" 2>/dev/null || true
}

# 对目录树下所有文件执行 Agent 树替换
rewrite_agent_tree() {
  local root="$1" agent_slash="$2" docs_slash="$3"
  [[ -d "$root" ]] || return 0
  local f
  while IFS= read -r -d '' f; do
    rewrite_agent_file "$f" "$agent_slash" "$docs_slash"
  done < <(find "$root" -type f -print0 2>/dev/null || true)
}


# ─── 核心安装步骤 ─────────────────────────────────────────────────────────────

# 将单个文件从 application/ 树复制到目标文档根，并做全文替换
application_copy_one() {
  local src_f="$1" dst_f="$2" agent_slash="$3" docs_slash="$4"
  if [[ "${CFG[dry_run]}" == "1" ]]; then
    log "[dry-run] $src_f → $dst_f"
    log "[dry-run] rewrite_doc_file 已跳过规则：system/->docs_slash；SYSTEM_INDEX/APPLICATION_INDEX->INDEX_GUIDE；system_meta/application_meta->docs_meta；word-boundary system->application(case-insensitive)；系统->应用（文件: ${dst_f}）"
    return 0
  fi
  if [[ -e "$dst_f" ]]; then
    local _ow=0
    should_overwrite "$dst_f" || _ow=$?
    [[ "$_ow" -eq 2 ]] && exit 130
    [[ "$_ow" -eq 1 ]] && { log "[skip] $dst_f"; return 0; }
    backup_path "$dst_f"
  fi
  ensure_dir "$(dirname "$dst_f")"
  cp "$src_f" "$dst_f"
  rewrite_doc_file "$dst_f" "$agent_slash" "$docs_slash"
}

# 步骤 1a：application/ 全量 → 目标（standalone 或默认）
install_application_full_to_docs() {
  local src_root="${CFG[repo_root]}/application"
  local dst_root="${CFG[docs_abs]}"
  local agent_slash="${CFG[primary_agent_slash]}"
  local docs_slash="${CFG[docs_slash]}"

  [[ -d "$src_root" ]] || error "未找到 application 目录: $src_root"

  info ">>> 初始化 application/（全量）→ 目标文档目录"
  info "    源:   $src_root"
  info "    目标: $dst_root"
  info "    type: application  |  .agent/ → ${agent_slash}  |  system/ → ${docs_slash}"

  local rel src_f dst_f base
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    base="${rel##*/}"
    [[ "$base" == "DESIGN.md" || "$base" == "CONTRIBUTING.md" ]] && continue

    src_f="$src_root/$rel"
    dst_f="$dst_root/$(map_path_system_to_application "$rel")"
    application_copy_one "$src_f" "$dst_f" "$agent_slash" "$docs_slash"
  done < <(cd "$src_root" && find . -type f -print0)

  info "    application/ 全量同步完成"
}

# 步骤 1b：application/ §2.1 核心子集（仅 central + type=application 显式）
install_application_subset_to_docs() {
  local src_root="${CFG[repo_root]}/application"
  local dst_root="${CFG[docs_abs]}"
  local agent_slash="${CFG[primary_agent_slash]}"
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
      dst_f="$dst_root/$d/$(map_path_system_to_application "$rel")"
      application_copy_one "$src_f" "$dst_f" "$agent_slash" "$docs_slash"
    done < <(cd "$src_root/$d" && find . -type f -print0)
  done

  for base in INDEX_GUIDE.md README.md docs_meta.yaml manifest.yaml; do
    [[ -f "$src_root/$base" ]] || continue
    application_copy_one "$src_root/$base" "$dst_root/$(map_path_system_to_application "$base")" "$agent_slash" "$docs_slash"
  done

  info "    application/ §2.1 子集同步完成"
}

# 步骤 1c：仓库顶层 system/ 或 company/ → 目标（组织级 / 公司级知识库根）
install_org_template_to_docs() {
  local label="$1"
  local src_root="$2"
  local dst_root="${CFG[docs_abs]}"
  local agent_slash="${CFG[primary_agent_slash]}"
  local docs_slash="${CFG[docs_slash]}"

  [[ -d "$src_root" ]] || error "未找到 ${label}/ 目录: $src_root"

  info ">>> 初始化 ${label}/ → 目标文档目录（${label} 知识库根）"
  info "    源:   $src_root"
  info "    目标: $dst_root"

  local rel src_f dst_f
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    src_f="$src_root/$rel"
    dst_f="$dst_root/$(map_path_system_to_application "$rel")"

    if [[ "${CFG[dry_run]}" == "1" ]]; then
      log "[dry-run] $src_f → $dst_f"
      continue
    fi
    if [[ -e "$dst_f" ]]; then
      local _ow=0
      should_overwrite "$dst_f" || _ow=$?
      [[ "$_ow" -eq 2 ]] && exit 130
      [[ "$_ow" -eq 1 ]] && { log "[skip] $dst_f"; continue; }
      backup_path "$dst_f"
    fi
    ensure_dir "$(dirname "$dst_f")"
    cp "$src_f" "$dst_f"
    rewrite_agent_file "$dst_f" "$agent_slash" "$docs_slash"
  done < <(cd "$src_root" && find . -type f -print0)

  info "    ${label}/ 同步完成"
}

# 步骤 1：按 type × mode 分发
install_system_to_docs() {
  case "${CFG[type]}" in
    application)
      if [[ "${CFG[mode]}" == "central" ]]; then
        install_application_subset_to_docs
      else
        install_application_full_to_docs
      fi
      ;;
    system)
      install_org_template_to_docs "system" "${CFG[repo_root]}/system"
      ;;
    company)
      install_org_template_to_docs "company" "${CFG[repo_root]}/company"
      ;;
    *)
      error "内部错误：未知 type=${CFG[type]}"
      ;;
  esac
}

# 步骤 2a：.agent/skills → 各 Agent 目录
install_agent_skills() {
  local docs_slash="${CFG[docs_slash]}"
  local agent agent_dir agent_slash

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"

    info ">>> 安装 ${agent} Agent skills"
    if [[ -n "${CFG[docs_abs]:-}" ]]; then
      info "    目录: ${agent_dir}；目标工程根下（${CFG[target_dir]}）"
    else
      info "    目录: ${agent_dir}；用户主目录下 Agent 配置"
    fi
    info "    .agent/ → ${agent_slash}  |  system/ → ${docs_slash}"

    ensure_dir "$agent_dir/skills"

    # 安装所有 skill 子目录
    local -a skill_dirs=()
    local sd skill
    shopt -s nullglob
    for sd in "${CFG[repo_root]}/.agent/skills"/*/; do
      [[ -d "$sd" ]] && skill_dirs+=("$sd")
    done

    if (( ${#skill_dirs[@]} == 0 )); then
      warn "未找到 .agent/skills 下的技能子目录"
    else
      for sd in "${skill_dirs[@]}"; do
        skill="$(basename "$sd")"
        copy_dir "$sd" "$agent_dir/skills/$skill"
      done
    fi

    [[ -f "${CFG[repo_root]}/.agent/skills/README.md" ]] \
      && copy_file "${CFG[repo_root]}/.agent/skills/README.md" "$agent_dir/skills/README.md"

    # 内容替换（非 dry-run）
    if [[ "${CFG[dry_run]}" == "0" ]]; then
      rewrite_agent_tree "$agent_dir/skills" "$agent_slash" "$docs_slash"
    fi
  done
}

# 步骤 2b：.agent/rules → 各 Agent 目录
install_agent_rules() {
  local docs_slash="${CFG[docs_slash]}"
  local agent agent_dir agent_slash

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"

    info ">>> 安装 ${agent} Agent rules"
    if [[ -n "${CFG[docs_abs]:-}" ]]; then
      info "    目录: ${agent_dir}；目标工程根下（${CFG[target_dir]}）"
    else
      info "    目录: ${agent_dir}；用户主目录下 Agent 配置"
    fi
    info "    .agent/ → ${agent_slash}  |  system/ → ${docs_slash}"

    ensure_dir "$agent_dir/rules"

    # 安装 rules（目录和文件分别处理）
    local rules_src="${CFG[repo_root]}/.agent/rules"
    if [[ -d "$rules_src" ]]; then
      ensure_dir "$agent_dir/rules"
      local item base
      shopt -s nullglob
      for item in "$rules_src"/*; do
        base="$(basename "$item")"
        if [[ -d "$item" ]]; then
          copy_dir  "$item" "$agent_dir/rules/$base"
        else
          copy_file "$item" "$agent_dir/rules/$base"
        fi
      done
    fi

    # 内容替换（非 dry-run）
    if [[ "${CFG[dry_run]}" == "0" ]]; then
      rewrite_agent_tree "$agent_dir/rules"  "$agent_slash" "$docs_slash"
    fi
  done
}


# ─── Central 模式 ─────────────────────────────────────────────────────────────

# 解析 central 模式的 APP ID 与 slug
resolve_central_ids() {
  local project_name
  project_name="$(basename "${CFG[target_dir]}")"
  if [[ -n "${CFG[app_id_opt]}" ]]; then
    CFG[central_app_id]="${CFG[app_id_opt]}"
  else
    CFG[central_app_id]="$(sanitize_app_id "$project_name")"
  fi
  CFG[central_app_slug]="${CFG[central_app_id]#APP-}"
  [[ -n "${CFG[central_app_slug]}" ]] || CFG[central_app_slug]="APPNAME"
}

# 在 application/INDEX_GUIDE.md 中插入或更新应用登记行（「十、中央知识库接入工程」）
upsert_system_index() {
  local app_id="$1" repo_or_path="$2" docs_path="$3"
  local idx="${CFG[repo_root]}/application/INDEX_GUIDE.md"
  [[ -f "$idx" ]] || error "未找到 application/INDEX_GUIDE.md: $idx"

  local section="## 十、中央知识库接入工程"
  local header="| APP ID | 工程路径（Git 或绝对路径） | 文档目录 |"
  local sep="|--------|---------------------------|----------|"
  local row="| ${app_id} | ${repo_or_path} | ${docs_path} |"

  if [[ "${CFG[dry_run]}" == "1" ]]; then
    log "[dry-run] 更新 ${idx} : ${row}"
    return 0
  fi

  # 节不存在 → 追加整节
  if ! grep -qF "$section" "$idx"; then
    { printf '\n%s\n\n本节用于在本仓库（中央知识库）登记各目标工程的接入信息，便于追溯与映射。\n\n%s\n%s\n%s\n\n' \
        "$section" "$header" "$sep" "$row"; } >> "$idx"
    return 0
  fi

  local tmp="${idx}.tmp"
  if grep -qF "| ${app_id} |" "$idx"; then
    # 已有该 APP ID → 替换行
    awk -v app="| ${app_id} |" -v newrow="$row" \
      'index($0, app)==1 { print newrow; next } { print }' "$idx" > "$tmp"
  else
    # 追加到表格分隔行之后
    awk -v sep="$sep" -v newrow="$row" \
      '{ print } $0==sep { print newrow }' "$idx" > "$tmp"
  fi
  mv "$tmp" "$idx"
}

# 在本仓库 system/application-<slug>/ 建立联邦槽位（applications/app-* 模板已移除时的目标态）
ensure_app_mirror() {
  local dest="${CFG[repo_root]}/system/application-${CFG[central_app_slug]}"
  local project_name
  project_name="$(basename "${CFG[target_dir]}")"

  info ">>> 中央模式：建立 system/application-${CFG[central_app_slug]}/ 联邦槽位"
  info "    目录:   $dest"
  info "    APP ID: ${CFG[central_app_id]}"

  if [[ "${CFG[dry_run]}" == "1" ]]; then
    log "[dry-run] 创建/更新联邦槽位: $dest"
    return 0
  fi

  ensure_dir "$dest"

  local slug="${CFG[central_app_slug]}" app_id="${CFG[central_app_id]}"

  if [[ ! -f "$dest/README.md" ]]; then
    {
      printf '# application-%s\n\n' "$slug"
      printf '本目录由 `docs-init --mode=central --type=application` 在中央库 `%s` 下生成，作为应用联邦槽位（知识库 v2）。\n\n' "$(basename "${CFG[repo_root]}")"
      printf '- **APP ID**：`%s`\n' "$app_id"
      printf '- **目标工程**：`%s`\n' "$project_name"
      printf '- 同步文档镜像见 `docs-fetch` / 设计文档 `docs/superpowers/specs/2026-04-07-knowledge-layout-v2-design.md`。\n'
    } >"$dest/README.md"
  fi

  info "    联邦槽位就绪"
}

# 步骤 3（central）：登记 + 建镜像
# 推荐顺序：先 --scope=config 写 .docsconfig → 再同步知识库（默认 --scope=ck 或 knowledge / all）→ 最后 central 登记；不强制要求目标侧已有 knowledge/ 目录。
install_central() {
  resolve_central_ids

  local repo_ref git_root repo_or_path docs_path
  repo_ref="$(git_repo_ref  "${CFG[target_dir]}")"
  git_root="$(git_root_path "${CFG[target_dir]}")"
  repo_or_path="${repo_ref:-${CFG[target_dir]}}"
  docs_path="$(docs_rel_to_git_root "$git_root" "${CFG[docs_abs]}")"

  info ">>> 中央模式：登记到本仓库 application/INDEX_GUIDE.md（十）并建立联邦槽位"
  info "    APP ID: ${CFG[central_app_id]}"
  info "    工程:   $repo_or_path"
  info "    文档:   ${CFG[docs_abs]}"

  upsert_system_index "${CFG[central_app_id]}" "$repo_or_path" "${CFG[docs_abs]}"
  ensure_app_mirror
}


# ─── CLI ──────────────────────────────────────────────────────────────────────

usage() {
  cat >&2 <<'EOF'
用法
  docs-init [选项] [<目标工程文档目录>]

说明
  按 --type 从本仓库 application/、system/ 或 company/ 同步到目标工程文档目录，并安装 .agent/skills、.agent/rules。
  未指定 <目标工程文档目录> 时，安装到用户主目录下 ~/.cursor、~/.trea 等；指定时，安装到工程根目录下的 .cursor、.trea 等（工程根为文档目录的父目录）。

  <目标工程文档目录>
    目标工程内的文档子目录，例如：
      ~/workspace/my-app/system
      ~/workspace/my-app/docs
    父目录（工程根）默认不已存在；使用 -r 可允许自动创建。
    在 standalone 模式下，若 --scope 仅为 s / r / rs，可省略本参数（不落地工程文档时）。
    central 模式、或 scope 为 all / knowledge / ck 时，必须提供本参数。

  替换规则
    文件名  : system（不区分大小写）→ application
    文件内容: .agent/        → 首个 Agent 目录（如 .cursor/）
              其余规则（system/、SYSTEM_INDEX/APPLICATION_INDEX、system_meta/application_meta、
                       词界 system、系统）在 rewrite_doc_file 中均跳过，并打印日志

  模式（--mode）
    standalone（默认）  仅目标工程落盘
    central               可额外在本仓库登记（见下「type」）

  类型（--type，知识库 v2）
    未指定时：standalone → application（全量 application/）；central → system（仓库 system/ → 目标，作为组织级系统知识库根）
    application           应用知识库：standalone 全量同步 application/；central 仅 §2.1 子集 + 登记 + system/application-<slug>/ 槽位
    system                仓库顶层 system/ → 目标（显式）
    company               仓库顶层 company/ → 目标（显式）
    别名：a|application，s|system，c|company

  central + type=application 时：在源知识库登记目标工程；推荐先 config、再同步知识库、最后 central；不要求目标 DOC_ROOT 下已存在 knowledge/。

选项
  --mode=MODE           standalone(s 默认) | central(c）  [默认: s]
  --type=TYPE           application(a) | system(s) | company(c) [默认 a]
  --scope=SCOPE         ck | config(c) | knowledge(k) | skills(s) | rules(r) | rs | all(a)  [默认: ck]
                        - ck（默认）同步知识库 + 写入目标 .docsconfig
                        - config(c) 仅登记文档路径 .docsconfig（DOC_ROOT/REPO_ROOT/DOC_DIR）
                        - knowledge(k) 仅同步知识库
                        - skills(s) 仅安装 Agent skills
                        - rules(r)  仅安装 Agent rules
                        - rs        同时安装 skills + rules（等同 r + s）
                        - all(a)    全量：知识库 + .docsconfig + Agent skills/rules
                        - all/knowledge/ck：同步前会将 DOC_DIR 现有内容备份到 .docs-init/<timestamp>/，并清空 DOC_DIR 后再写入
                        - config/skills/rules/rs：不触发 DOC_DIR 清空；config 仅重算并写入（已存在则覆盖）.docsconfig
  --app-id=APP-ID       central 模式下的 APP ID [默认: 由工程目录名推导]
  --agents=LIST         cursor | trea | claude | all，逗号分隔 [默认: cursor]
  -r                    允许工程根目录不存在时自动创建
  --force               强制覆盖，不提示
  --dry-run             预览模式，不写入任何文件
  -h, --help            显示此帮助

环境变量
  REPO_ROOT             本仓库根目录（默认自动探测）
  HOME                  用户主目录；安装 Agent skills/rules 时必需（未指定文档目录时作为 ~/.cursor 等安装根）
  CREATE_PROJECT_ROOT   1=允许自动创建工程根（等同 -r）| 0=要求工程根已存在（默认）
  SCOPE                 未传 --scope 时默认 ck（见上）
  DRY_RUN               1=预览模式
  FORCE                 1=强制覆盖

示例
  # 最简用法（默认 scope=ck：知识库 + .docsconfig，不装 skills）
  docs-init ~/workspace/my-app/docs

  # 全量（含 Agent skills/rules，等同旧默认 all）
  docs-init --scope=all ~/workspace/my-app/docs

  # 仅同步知识库
  docs-init --scope=knowledge ~/workspace/my-app/docs
  docs-init --scope=k ~/workspace/my-app/docs

  # 仅登记文档路径 .docsconfig（DOC_ROOT/REPO_ROOT/DOC_DIR）
  docs-init --scope=config ~/workspace/my-app/docs
  docs-init --scope=c ~/workspace/my-app/docs

  # 仅安装 Agent skills（未指定文档目录 → ~/.cursor 等；指定文档目录 → <工程根>/.cursor 等）
  docs-init --scope=skills 
  docs-init --scope=skills ~/workspace/my-app/docs
  docs-init --scope=s ~/workspace/my-app/docs

  # 仅安装 Agent rules（路径规则同上；不落地 docs 文档时可省略文档目录）
  docs-init --scope=rules
  docs-init --scope=rules ~/workspace/my-app/docs

  # 同时安装 skills + rules（可省略文档目录）
  docs-init --scope=rs
  docs-init --scope=rs ~/workspace/my-app/docs

  # central 模式，指定 APP ID，安装 cursor 和 trea
  docs-init --mode=central --app-id=APP-MYAPP --agents=cursor,trea ~/workspace/my-app/docs

  # 预览，不实际写入
  docs-init --dry-run ~/workspace/my-app/docs

EOF
}

parse_args() {
  while (( $# > 0 )); do
    case "$1" in
      --mode=*)           CFG[mode]="${1#*=}";       shift ;;
      --mode)             shift; CFG[mode]="${1:-}";  shift ;;
      --scope=*)          CFG[scope]="${1#*=}"; shift ;;
      --scope)            shift; CFG[scope]="${1:-}"; shift ;;
      --type=*)           CFG[type]="${1#*=}"; CFG[type_explicit]=1; shift ;;
      --type)             shift; CFG[type]="${1:-}"; CFG[type_explicit]=1; shift ;;
      --app-id=*)         CFG[app_id_opt]="${1#*=}"; shift ;;
      --app-id)           shift; CFG[app_id_opt]="${1:-}"; shift ;;
      --agents=*)         CFG[agents_opt]="${1#*=}"; shift ;;
      --agents)
        shift
        local -a parts=()
        while (( $# > 0 )); do
          case "$1" in -*) break ;; *) parts+=("$1"); shift ;; esac
        done
        (( ${#parts[@]} > 0 )) || error "缺少 --agents 值（如 cursor,trea 或 cursor trea）"
        CFG[agents_opt]="$(IFS=','; printf '%s' "${parts[*]}")"
        ;;
      --dry-run)          CFG[dry_run]=1;            shift ;;
      --force)            CFG[force]=1;              shift ;;
      -r)                 CFG[create_project_root]=1; shift ;;
      -h|--help)          usage; exit 0 ;;
      -*)                 error "未知选项: $1" ;;
      *)
        [[ -z "${CFG[docs_abs]}" ]] || error "多余的参数: $1（文档目录已指定为 ${CFG[docs_abs]}）"
        CFG[docs_abs]="$1"
        shift
        ;;
    esac
  done
}


# ─── 初始化与校验 ─────────────────────────────────────────────────────────────

init_repo_root() {
  if [[ -z "${CFG[repo_root]}" ]]; then
    CFG[repo_root]="$(abs_path "$SCRIPT_DIR/..")"
  fi
  [[ -d "${CFG[repo_root]}/application" ]] || error "未找到 application 目录: ${CFG[repo_root]}/application"
  [[ -d "${CFG[repo_root]}/.agent/skills" ]] || error "未找到 .agent/skills: ${CFG[repo_root]}/.agent/skills"
  [[ -d "${CFG[repo_root]}/.agent/rules"  ]] || error "未找到 .agent/rules: ${CFG[repo_root]}/.agent/rules"
}

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
    if [[ "${CFG[create_project_root]}" == "1" ]]; then
      run_or_dry mkdir -p "$target_dir"
      [[ "${CFG[dry_run]}" == "0" ]] && info "已创建工程根目录: $target_dir"
    else
      error "工程根目录不存在: ${target_dir}（请先创建，或使用 -r 自动创建）"
    fi
  fi
}

apply_mode() {
  CFG[mode]="$(normalize_mode "${CFG[mode]}")"
  validate_mode "${CFG[mode]}" || error "无效模式: ${CFG[mode]}（standalone/central 或 s/c）"
}

validate_sync_scope() {
  # 允许组合：rs / sr
  case "${CFG[scope]}" in
    rs|sr) CFG[scope]="rs" ;;
  esac

  # ck = 登记 .docsconfig + 同步知识库（同 knowledge），不含 skills/rules；须在 c / config 之前匹配，避免被 c 截断
  # c / config / cfg → config（仅写 .docsconfig）；其余单字母缩写
  case "${CFG[scope]}" in
    ck) ;;
    a) CFG[scope]="all" ;;
    c|config|cfg) CFG[scope]="config" ;;
    s) CFG[scope]="skills" ;;
    r) CFG[scope]="rules" ;;
    k) CFG[scope]="knowledge" ;;
  esac

  case "${CFG[scope]}" in
    all|skills|rules|rs|knowledge|config|ck) ;;
    *)
      error "无效 --scope: ${CFG[scope]}（支持 ck、all/a、knowledge/k、skills/s、rules/r、rs、config/c）"
      ;;
  esac

}

apply_agents() {
  validate_agents "${CFG[agents_opt]}" \
    || error "无效 --agents: ${CFG[agents_opt]}（支持 cursor、trea、claude、all 及逗号分隔组合）"
  read -ra ENABLED_AGENTS <<< "$(normalize_agents "${CFG[agents_opt]}")"
  (( ${#ENABLED_AGENTS[@]} > 0 )) || error "未解析到任何 Agent"
}

# 解析 --type：未指定时 standalone → application；central → system（见知识库 v2 设计 §2.3）
resolve_type() {
  if [[ "${CFG[type_explicit]}" == "1" ]]; then
    CFG[type]="$(normalize_type "${CFG[type]}")"
    validate_type "${CFG[type]}" || error "无效 --type: ${CFG[type]}（application(a)|system(s)|company(c)；别名 app、sys、comp）"
  else
    if [[ "${CFG[mode]}" == "central" ]]; then
      CFG[type]=system
    else
      CFG[type]=application
    fi
  fi
}

validate_type_sources() {
  case "${CFG[type]}" in
    application)
      [[ -d "${CFG[repo_root]}/application" ]] || error "未找到 application/: ${CFG[repo_root]}/application"
      ;;
    system)
      [[ -d "${CFG[repo_root]}/system" ]] || error "未找到 system/: ${CFG[repo_root]}/system（type=system）"
      ;;
    company)
      [[ -d "${CFG[repo_root]}/company" ]] || error "未找到 company/: ${CFG[repo_root]}/company（type=company）"
      ;;
  esac
}

# 写入目标工程仓库根 .docsconfig（DOC_ROOT / REPO_ROOT / DOC_DIR）；dry-run 时仅预览
# 见 docs/superpowers/specs/2026-04-08-docsconfig-docs-init-design.md §2.3 / §3.3
write_target_docsconfig() {
  local doc_root repo_target dd cfg_file existed=0
  doc_root="${CFG[docs_abs]}"
  repo_target="$(docsconfig_repo_root_from_doc_root "$doc_root")"
  if [[ -z "$repo_target" ]]; then
    repo_target="$(docsconfig_repo_root_fallback_from_doc_root "$doc_root")"
    [[ -n "$repo_target" ]] \
      || error "无法写入 .docsconfig：DOC_ROOT 父目录不可解析: $doc_root"
    warn "未检测到 DOC_ROOT 所在 Git 仓库，已回退使用父目录作为 REPO_ROOT: $repo_target"
  fi
  dd="$(docsconfig_doc_dir_from_roots "$repo_target" "$doc_root")" \
    || error "无法计算 DOC_DIR（DOC_ROOT 须位于 REPO_ROOT 目录下）"
  cfg_file="$repo_target/.docsconfig"
  [[ -f "$cfg_file" ]] && existed=1
  if [[ "$existed" == "1" ]]; then
    info ".docsconfig 已存在，将按当前路径重算并覆盖写入: $cfg_file"
  else
    info ".docsconfig 不存在，将创建并写入: $cfg_file"
  fi
  docsconfig_write "$repo_target" "$doc_root" "$dd" "${CFG[dry_run]}"
}

compute_derived_paths() {
  CFG[primary_agent_slash]="$(get_agent_dir "${ENABLED_AGENTS[0]}")/"
  if [[ -n "${CFG[docs_abs]}" ]]; then
    CFG[docs_slash]="$(compute_docs_rel_slash "${CFG[target_dir]}" "${CFG[docs_abs]}")"
  else
    # standalone + scope 为 s/r/rs 且未传文档目录时：无法计算相对工程根前缀，采用约定默认值
    CFG[docs_slash]='docs/'
  fi
}

# ─── 完成提示 ─────────────────────────────────────────────────────────────────

print_checklist() {
  log ""
  log "─────────────────────────────────────────────────────────────────────────"
  if [[ -n "${CFG[docs_abs]}" ]]; then
    log "docs-init 完成  目标: ${CFG[docs_abs]}"
  else
    log "docs-init 完成  目标: （未指定工程文档目录，仅更新用户主目录 Agent 配置）"
  fi
  log "─────────────────────────────────────────────────────────────────────────"
  if [[ -n "${CFG[docs_abs]}" ]]; then
    post_init_checklist "${CFG[docs_abs]}" >&2
  else
    post_init_checklist "<未指定工程文档目录>" >&2
  fi
}

# ─── 入口 ─────────────────────────────────────────────────────────────────────

main() {
  parse_args "$@"

  init_repo_root
  validate_sync_scope
  apply_mode
  resolve_type

  # config + central 且未显式 --type：默认 application（与「向源知识库登记应用知识库」一致）
  if [[ "${CFG[scope]}" == "config" && "${CFG[mode]}" == "central" && "${CFG[type_explicit]}" == "0" ]]; then
    CFG[type]=application
  fi

  validate_type_sources

  # 仅写目标工程 .docsconfig；可选 --mode=central 在本仓库（源知识库）登记目标工程
  if [[ "${CFG[scope]}" == "config" ]]; then
    [[ -n "${CFG[docs_abs]}" ]] \
      || error "必须提供 <目标工程文档目录>（--scope=config）"
    validate_docs_and_target
    write_target_docsconfig
    if [[ "${CFG[mode]}" == "central" ]]; then
      if [[ "${CFG[type]}" == "application" ]]; then
        install_central
      else
        warn "central 向源知识库登记需 --type=application（当前为 ${CFG[type]}），已仅写入 .docsconfig"
      fi
    fi
    info "完成：docs-init（--scope=config）"
    print_checklist
    exit 0
  fi

  # 未提供 <目标工程文档目录> 时的合法性（方案 A：s/r/rs + standalone 可省略）
  if [[ -z "${CFG[docs_abs]}" ]]; then
    if [[ "${CFG[mode]}" == "central" ]]; then
      error "central 模式必须指定 <目标工程文档目录>"
    fi
    case "${CFG[scope]}" in
      all|knowledge|ck)
        usage
        exit 2
        ;;
    esac
  fi

  if [[ -n "${CFG[docs_abs]}" ]]; then
    validate_docs_and_target
  fi

  apply_agents
  compute_derived_paths

  DOC_INIT_STAMP="$(date +%Y-%m-%d_%H-%M-%S)"

  if needs_agent_install; then
    [[ -n "${HOME:-}" ]] || error "需要 HOME 环境变量以安装 Agent skills/rules"
    CFG[home_abs]="$(abs_path "$HOME")"
  fi

  if [[ -z "${CFG[docs_abs]}" ]] && needs_agent_install; then
    warn "未指定工程文档目录：Agent 配置中 system/ → 文档前缀将默认替换为 docs/（相对工程根）；若需与真实目录一致请传入 <目标工程文档目录>"
  fi

  have_perl || warn "未检测到 perl：文件内容替换将被跳过，建议安装 perl。"

  if should_reset_docs_dir_before_sync; then
    reset_docs_dir_with_backup
  fi

  if [[ "${CFG[scope]}" == "all" || "${CFG[scope]}" == "knowledge" || "${CFG[scope]}" == "ck" ]]; then
    if [[ "${CFG[mode]}" == "central" && "${CFG[type_explicit]}" == "0" && "${CFG[type]}" == "system" ]]; then
      info "提示：central 且未传 --type 时默认 type=system（同步仓库 system/ → 目标）。若需应用知识库 §2.1 子集并登记，请使用 --type=application"
    fi
    install_system_to_docs
  fi

  if [[ "${CFG[mode]}" == "central" && "${CFG[type]}" == "application" ]]; then
    install_central
  fi

  case "${CFG[scope]}" in
    all)
      install_agent_skills
      install_agent_rules
      ;;
    skills)
      install_agent_skills
      ;;
    rules)
      install_agent_rules
      ;;
    rs)
      install_agent_rules
      install_agent_skills
      ;;
  esac

  # §2.3：已提供文档根且非 dry-run（或 dry-run 预览）时同步 .docsconfig
  if [[ -n "${CFG[docs_abs]}" ]]; then
    write_target_docsconfig
  fi

  info "完成：docs-init"
  print_checklist
}

main "$@"
