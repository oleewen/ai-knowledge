#!/usr/bin/env bash
# docs-init：将本仓库 system/ 模板初始化到目标工程文档目录，并安装 Agent skills/rules
#
# 步骤：
#   1. system/ → 目标文档目录（排除 DESIGN.md、CONTRIBUTING.md）
#      - 文件名：system（不区分大小写）→ application
#      - 文件内容：.ai/ → Agent 目录；system/ → 文档根相对路径；系统 → 应用
#   2. .ai/skills + .ai/rules → 所选 Agent 目录
#      - 文件内容：.ai/ → Agent 目录；system/ → 文档根相对路径
#   3. central 模式：注册应用到系统知识库索引 + 建立 app-APPNAME 镜像
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
  [scope]="${SCOPE:-all}"
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
)

declare -a ENABLED_AGENTS=()

# 冲突处理模式（交互状态，不放入 CFG 避免混淆）
_CONFLICT_MODE="${CONFLICT_PROMPT_MODE:-}"
_BACKUP_ROOT="${BACKUP_ROOT:-}"


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
    newp="$(perl -CSD -pe 's/SYSTEM_INDEX/APPLICATION_INDEX/gi; s/system/application/gi' <<< "$p")"
    out="${out}${sep}${newp}"
    sep="/"
  done
  printf '%s' "$out"
}

# 计算目标工程根相对文档目录路径（带尾斜杠）
# 用于将模板中字面量 system/ 替换为实际文档前缀
compute_docs_rel_slash() {
  local root docs
  root="$(sdx_strip_trailing_slash "$1")"
  docs="$(sdx_strip_trailing_slash "$2")"
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
  [[ -n "$root" ]] && printf '%s' "$(sdx_abs_path "$root")" || printf ''
}

# 探测目标目录所在 Git 仓库根路径
git_root_path() {
  local target="$1"
  have_cmd git || { printf ''; return 0; }
  git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1 || { printf ''; return 0; }
  local root
  root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -n "$root" ]] && printf '%s' "$(sdx_abs_path "$root")" || printf ''
}

# 返回 docs_abs 相对于 git_root 的路径（或绝对路径）
docs_rel_to_git_root() {
  local git_root docs_abs
  git_root="$(sdx_strip_trailing_slash "$1")"
  docs_abs="$(sdx_strip_trailing_slash "$2")"
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

# 获取（或初始化）本次运行的备份根目录
_get_backup_root() {
  if [[ -z "$_BACKUP_ROOT" ]]; then
    local stamp
    stamp="$(date +%Y-%m-%d_%H-%M-%S)"
    _BACKUP_ROOT="${CFG[target_dir]:-$PWD}/.docs-init/${stamp}"
  fi
  printf '%s' "$_BACKUP_ROOT"
}

# 将已存在的路径备份到 .docs-init/<timestamp>/
backup_path() {
  local existing="$1"
  local backup_root rel backup_target
  backup_root="$(_get_backup_root)"
  if [[ -n "${CFG[target_dir]}" && "$existing" == "${CFG[target_dir]}/"* ]]; then
    rel="${existing#"${CFG[target_dir]}"/}"
  else
    rel="${existing#/}"
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

# 文档树替换：.ai/ → agent_slash；system/ → docs_slash；系统→应用；词界 system→application
_rewrite_doc_file() {
  local file="$1" agent_slash="$2" docs_slash="$3"
  [[ -f "$file" ]] && is_text_file "$file" || return 0
  have_perl || { warn "未安装 perl，跳过内容替换：$file"; return 0; }
  SDX_AGENT_SLASH="$agent_slash" SDX_DOCS_SLASH="$docs_slash" \
    perl -CSD -i -pe '
      s{\.ai/}{$ENV{SDX_AGENT_SLASH}}g;
      s{system/}{$ENV{SDX_DOCS_SLASH}}gi;
      s{SYSTEM_INDEX}{APPLICATION_INDEX}gi;
      s{system_meta}{application_meta}gi;
      s{\bsystem\b}{application}gi;
      s{系统}{应用}g;
    ' "$file" 2>/dev/null || true
}

# Agent 树替换：.ai/ → agent_slash；system/ → docs_slash（不做 system→application 词替换）
_rewrite_agent_file() {
  local file="$1" agent_slash="$2" docs_slash="$3"
  [[ -f "$file" ]] && is_text_file "$file" || return 0
  have_perl || return 0
  SDX_AGENT_SLASH="$agent_slash" SDX_DOCS_SLASH="$docs_slash" \
    perl -CSD -i -pe '
      s{\.ai/}{$ENV{SDX_AGENT_SLASH}}g;
      s{system/}{$ENV{SDX_DOCS_SLASH}}gi;
    ' "$file" 2>/dev/null || true
}

# 对目录树下所有文件执行 Agent 树替换
rewrite_agent_tree() {
  local root="$1" agent_slash="$2" docs_slash="$3"
  [[ -d "$root" ]] || return 0
  local f
  while IFS= read -r -d '' f; do
    _rewrite_agent_file "$f" "$agent_slash" "$docs_slash"
  done < <(find "$root" -type f -print0 2>/dev/null || true)
}


# ─── 核心安装步骤 ─────────────────────────────────────────────────────────────

# 步骤 1：system/ → 目标文档目录
install_system_to_docs() {
  local src_root="${CFG[repo_root]}/system"
  local dst_root="${CFG[docs_abs]}"
  local agent_slash="${CFG[primary_agent_slash]}"
  local docs_slash="${CFG[docs_slash]}"

  [[ -d "$src_root" ]] || error "未找到 system 目录: $src_root"

  info ">>> 初始化 system/ → 目标文档目录"
  info "    源:   $src_root"
  info "    目标: $dst_root"
  info "    .ai/ → ${agent_slash}  |  system/ → ${docs_slash}"

  local rel src_f dst_f base
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    base="${rel##*/}"
    # 排除不需要分发的文件
    [[ "$base" == "DESIGN.md" || "$base" == "CONTRIBUTING.md" ]] && continue

    src_f="$src_root/$rel"
    dst_f="$dst_root/$(map_path_system_to_application "$rel")"

    if [[ "${CFG[dry_run]}" == "1" ]]; then
      log "[dry-run] $src_f → $dst_f"; continue
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
    _rewrite_doc_file "$dst_f" "$agent_slash" "$docs_slash"
  done < <(cd "$src_root" && find . -type f -print0)

  info "    system/ 同步完成"
}

# 步骤 2a：.ai/skills → 各 Agent 目录
install_agent_skills() {
  local docs_slash="${CFG[docs_slash]}"
  local agent agent_dir agent_slash

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="${CFG[target_dir]}/$(sdx_get_agent_dir "$agent")"
    agent_slash="$(sdx_get_agent_dir "$agent")/"

    info ">>> 安装 ${agent} Agent skills"
    info "    目录: $agent_dir"
    info "    .ai/ → ${agent_slash}  |  system/ → ${docs_slash}"

    ensure_dir "$agent_dir/skills"

    # 安装所有 skill 子目录
    local -a skill_dirs=()
    local sd skill
    shopt -s nullglob
    for sd in "${CFG[repo_root]}/.ai/skills"/*/; do
      [[ -d "$sd" ]] && skill_dirs+=("$sd")
    done

    if (( ${#skill_dirs[@]} == 0 )); then
      warn "未找到 .ai/skills 下的技能子目录"
    else
      for sd in "${skill_dirs[@]}"; do
        skill="$(basename "$sd")"
        copy_dir "$sd" "$agent_dir/skills/$skill"
      done
    fi

    [[ -f "${CFG[repo_root]}/.ai/skills/README.md" ]] \
      && copy_file "${CFG[repo_root]}/.ai/skills/README.md" "$agent_dir/skills/README.md"

    # 内容替换（非 dry-run）
    if [[ "${CFG[dry_run]}" == "0" ]]; then
      rewrite_agent_tree "$agent_dir/skills" "$agent_slash" "$docs_slash"
    fi
  done
}

# 步骤 2b：.ai/rules → 各 Agent 目录
install_agent_rules() {
  local docs_slash="${CFG[docs_slash]}"
  local agent agent_dir agent_slash

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="${CFG[target_dir]}/$(sdx_get_agent_dir "$agent")"
    agent_slash="$(sdx_get_agent_dir "$agent")/"

    info ">>> 安装 ${agent} Agent rules"
    info "    目录: $agent_dir"
    info "    .ai/ → ${agent_slash}  |  system/ → ${docs_slash}"

    ensure_dir "$agent_dir/rules"

    # 安装 rules（目录和文件分别处理）
    local rules_src="${CFG[repo_root]}/.ai/rules"
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
_resolve_central_ids() {
  local project_name
  project_name="$(basename "${CFG[target_dir]}")"
  if [[ -n "${CFG[app_id_opt]}" ]]; then
    CFG[central_app_id]="${CFG[app_id_opt]}"
  else
    CFG[central_app_id]="$(sdx_sanitize_app_id "$project_name")"
  fi
  CFG[central_app_slug]="${CFG[central_app_id]#APP-}"
  [[ -n "${CFG[central_app_slug]}" ]] || CFG[central_app_slug]="APPNAME"
}

# 在 system/SYSTEM_INDEX.md 中插入或更新应用登记行
_upsert_system_index() {
  local app_id="$1" repo_or_path="$2" docs_path="$3"
  local idx="${CFG[repo_root]}/system/SYSTEM_INDEX.md"
  [[ -f "$idx" ]] || error "未找到 system/SYSTEM_INDEX.md: $idx"

  local section="## 五、中央知识库接入工程"
  local header="| APP ID | 工程路径（Git 或绝对路径） | 文档目录 |"
  local sep="|--------|---------------------------|----------|"
  local row="| ${app_id} | ${repo_or_path} | ${docs_path} |"

  if [[ "${CFG[dry_run]}" == "1" ]]; then
    log "[dry-run] 更新 $idx：$row"; return 0
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

# 建立 applications/app-<slug>/ 镜像并初始化 manifest
_ensure_app_mirror() {
  local tmpl="${CFG[repo_root]}/applications/app-APPNAME"
  local dest="${CFG[repo_root]}/applications/app-${CFG[central_app_slug]}"
  local project_name
  project_name="$(basename "${CFG[target_dir]}")"

  [[ -d "$tmpl" ]] || error "未找到联邦模板目录: $tmpl"

  info ">>> 中央模式：建立应用知识库镜像"
  info "    目录:   $dest"
  info "    APP ID: ${CFG[central_app_id]}"

  if [[ "${CFG[dry_run]}" == "1" ]]; then
    log "[dry-run] 创建镜像: $tmpl → $dest"; return 0
  fi

  ensure_dir "$dest"

  local slug="${CFG[central_app_slug]}" app_id="${CFG[central_app_id]}"

  if [[ -f "$tmpl/APPNAME_manifest.yaml" ]]; then
    copy_file "$tmpl/APPNAME_manifest.yaml" "$dest/APPNAME_manifest.yaml"
    if have_perl && [[ -f "$dest/APPNAME_manifest.yaml" ]]; then
      SDX_SLUG="$slug" SDX_PN="$project_name" SDX_AID="$app_id" \
        perl -i -CSD -pe '
          s/^template_id:.*/template_id: app-$ENV{SDX_SLUG}/;
          s/^description:.*/description: 联邦单元 $ENV{SDX_PN}（$ENV{SDX_AID}），由 docs-init central 模式生成/;
        ' "$dest/APPNAME_manifest.yaml" 2>/dev/null || true
    fi
  fi

  if [[ -f "$tmpl/README.md" ]]; then
    copy_file "$tmpl/README.md" "$dest/README.md"
    if have_perl && [[ -f "$dest/README.md" ]]; then
      perl -i -CSD -pe "
        s{applications/app-APPNAME}{applications/app-${slug}}g;
        s{app-APPNAME}{app-${slug}}g;
      " "$dest/README.md" 2>/dev/null || true
    fi
  fi

  info "    镜像初始化完成"
}

# Central 前置：目标文档目录下须已有 knowledge/（模板中的知识库树）
# dry-run 且本次会执行 install_system_to_docs 时，视为执行后将存在 knowledge/，允许中央预览
_central_knowledge_ready() {
  local k="${CFG[docs_abs]}/knowledge"
  [[ -d "$k" ]] && return 0
  [[ "${CFG[dry_run]}" == "1" && ( "${CFG[scope]}" == "all" || "${CFG[scope]}" == "knowledge" ) ]] && return 0
  return 1
}

# 步骤 3（central）：登记 + 建镜像
install_central() {
  _resolve_central_ids

  local repo_ref git_root repo_or_path docs_path
  repo_ref="$(git_repo_ref  "${CFG[target_dir]}")"
  git_root="$(git_root_path "${CFG[target_dir]}")"
  repo_or_path="${repo_ref:-${CFG[target_dir]}}"
  docs_path="$(docs_rel_to_git_root "$git_root" "${CFG[docs_abs]}")"

  info ">>> 中央模式：登记应用到系统知识库索引"
  info "    APP ID: ${CFG[central_app_id]}"
  info "    工程:   $repo_or_path"
  info "    文档:   ${CFG[docs_abs]}"

  _upsert_system_index "${CFG[central_app_id]}" "$repo_or_path" "${CFG[docs_abs]}"
  _ensure_app_mirror
}


# ─── CLI ──────────────────────────────────────────────────────────────────────

usage() {
  cat >&2 <<'EOF'
用法
  docs-init [选项] <目标工程文档目录>

说明
  将本仓库 system/ 目录同步到目标工程的文档目录，并将 .ai/skills、.ai/rules
  安装到所选 Agent 目录。

  <目标工程文档目录>
    目标工程内的文档子目录，例如：
      ~/workspace/my-app/system
      ~/workspace/my-app/docs
    父目录（工程根）默认不已存在；使用 -r 可允许自动创建。

  替换规则
    文件名  : system（不区分大小写）→ application
    文件内容: .ai/        → 首个 Agent 目录（如 .cursor/）
              system/     → 文档根相对路径（如 system/）
              系统        → 应用
              词界 system → application

  模式
    standalone（默认）  仅目标工程落盘
    central             同时在本仓库注册应用（更新 system/SYSTEM_INDEX.md）
                        并在 applications/app-<slug>/ 建立镜像
                        要求：目标文档目录下已存在 knowledge/ 子目录（未满足则跳过登记）

选项
  --mode=MODE           standalone | central（或缩写 s | c）  [默认: standalone]
  --scope=SCOPE         all(a) | knowledge(k) | skills(s) | rules(r) | rs  [默认: all]
                        - skills(s) 仅安装 Agent skills
                        - rules(r)  仅安装 Agent rules
                        - rs        同时安装 skills + rules（等同 r + s）
                        注：central 可与任意 scope 组合；仅 skills/rules/rs 时仍会登记本仓库索引与联邦镜像
  --app-id=APP-ID       central 模式下的 APP ID               [默认: 由工程目录名推导]
  --agents=LIST         cursor | trea | claude | all，逗号分隔 [默认: cursor]
  -r                    允许工程根目录不存在时自动创建
  --force               强制覆盖，不提示
  --dry-run             预览模式，不写入任何文件
  -h, --help            显示此帮助

环境变量
  REPO_ROOT             本仓库根目录（默认自动探测）
  CREATE_PROJECT_ROOT   1=允许自动创建工程根（等同 -r）| 0=要求工程根已存在（默认）
  DRY_RUN               1=预览模式
  FORCE                 1=强制覆盖

示例
  # 最简用法（standalone + cursor）
  docs-init ~/workspace/my-app/system

  # 仅同步知识库（不安装 Agent skills/rules）
  docs-init --scope=knowledge ~/workspace/my-app/system

  # 仅安装 Agent skills（不落地 system 文档）
  docs-init --scope=skills ~/workspace/my-app/system

  # 仅安装 Agent rules（不落地 system 文档）
  docs-init --scope=rules ~/workspace/my-app/system

  # 同时安装 Agent skills + rules（不落地 system 文档）
  docs-init --scope=rs ~/workspace/my-app/system

  # central 模式，指定 APP ID，安装 cursor 和 trea
  docs-init --mode=central --app-id=APP-MYAPP --agents=cursor,trea ~/workspace/my-app/system

  # 预览，不实际写入
  docs-init --dry-run ~/workspace/my-app/system

EOF
}

parse_args() {
  while (( $# > 0 )); do
    case "$1" in
      --mode=*)           CFG[mode]="${1#*=}";       shift ;;
      --mode)             shift; CFG[mode]="${1:-}";  shift ;;
      --scope=*)          CFG[scope]="${1#*=}"; shift ;;
      --scope)            shift; CFG[scope]="${1:-}"; shift ;;
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

_init_repo_root() {
  if [[ -z "${CFG[repo_root]}" ]]; then
    CFG[repo_root]="$(sdx_abs_path "$SCRIPT_DIR/..")"
  fi
  [[ -d "${CFG[repo_root]}/system"     ]] || error "未找到 system 目录: ${CFG[repo_root]}/system"
  [[ -d "${CFG[repo_root]}/.ai/skills" ]] || error "未找到 .ai/skills: ${CFG[repo_root]}/.ai/skills"
  [[ -d "${CFG[repo_root]}/.ai/rules"  ]] || error "未找到 .ai/rules: ${CFG[repo_root]}/.ai/rules"
}

_validate_docs_and_target() {
  [[ -n "${CFG[docs_abs]}" ]] || { usage; exit 2; }

  CFG[docs_abs]="$(sdx_strip_trailing_slash "$(sdx_abs_path "${CFG[docs_abs]}")")"
  CFG[target_dir]="$(sdx_abs_path "$(dirname "${CFG[docs_abs]}")")"

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

_validate_mode() {
  CFG[mode]="$(sdx_normalize_mode "${CFG[mode]}")"
  sdx_validate_mode "${CFG[mode]}" || error "无效模式: ${CFG[mode]}（standalone/central 或 s/c）"
}

_validate_sync_scope() {
  # 允许组合：rs / sr
  case "${CFG[scope]}" in
    rs|sr) CFG[scope]="rs" ;;
  esac

  case "${CFG[scope]}" in
    a) CFG[scope]="all" ;;
    s) CFG[scope]="skills" ;;
    r) CFG[scope]="rules" ;;
    k) CFG[scope]="knowledge" ;;
  esac

  case "${CFG[scope]}" in
    all|skills|rules|rs|knowledge) ;;
    *)
      error "无效 --scope: ${CFG[scope]}（支持 all/a、knowledge/k、skills/s、rules/r、rs）"
      ;;
  esac

}

_validate_agents() {
  sdx_validate_agents "${CFG[agents_opt]}" \
    || error "无效 --agents: ${CFG[agents_opt]}（支持 cursor、trea、claude、all 及逗号分隔组合）"
  read -ra ENABLED_AGENTS <<< "$(sdx_normalize_agents "${CFG[agents_opt]}")"
  (( ${#ENABLED_AGENTS[@]} > 0 )) || error "未解析到任何 Agent"
}

_compute_derived_paths() {
  CFG[primary_agent_slash]="$(sdx_get_agent_dir "${ENABLED_AGENTS[0]}")/"
  CFG[docs_slash]="$(compute_docs_rel_slash "${CFG[target_dir]}" "${CFG[docs_abs]}")"
}

# ─── 完成提示 ─────────────────────────────────────────────────────────────────

_print_checklist() {
  log ""
  log "─────────────────────────────────────────────────────────────────────────"
  log "docs-init 完成  目标: ${CFG[docs_abs]}"
  log "─────────────────────────────────────────────────────────────────────────"
  sdx_post_init_checklist "${CFG[docs_abs]}" >&2
}

# ─── 入口 ─────────────────────────────────────────────────────────────────────

main() {
  parse_args "$@"

  _init_repo_root
  _validate_docs_and_target
  _validate_mode
  _validate_sync_scope
  _validate_agents
  _compute_derived_paths

  have_perl || warn "未检测到 perl：文件内容替换将被跳过，建议安装 perl。"

  if [[ "${CFG[scope]}" == "all" || "${CFG[scope]}" == "knowledge" ]]; then
    install_system_to_docs
  fi

  if [[ "${CFG[mode]}" == "central" ]]; then
    if _central_knowledge_ready; then
      install_central
    else
      warn "central 模式已跳过：目标文档目录下须存在 knowledge/ 子目录（${CFG[docs_abs]}/knowledge）"
    fi
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

  info "完成：docs-init"
  _print_checklist
}

main "$@"
