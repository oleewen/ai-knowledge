#!/usr/bin/env bash
# knowledge-init：将本仓库 system/ 模板初始化到目标工程文档目录，并安装 Agent skills/rules
# 1. 初始化system目录下内容到目标工程文档目录（默认目录名`system`）
#   - system目录下CONTRIBUTING.md、DESIGN.md排除在外
#   - system目录下替换
#     - 文件名，system（不区分大小写）替换为application
#     - 文件内容，`.ai/` 替换为 Agent 目录，正文字面量 `system/` 替换为目标文档根相对路径（默认 `docs/`），`系统` 替换为 `应用`
# 2. 安装Agent Skills和Rules到选择的Agent 目录下，相关文件内容，`.ai/` 替换为 Agent 目录，正文字面量 `system/` 替换为目标文档根相对路径（默认 `docs/`）
# 3. 支持独立模式和中央模式，如果选择中央模式
#   - 注册应用知识库到系统知识库
#   - 建立应用知识库镜像（app-APPNAME目录），初始化APPNAME_manifest.yaml
# 运行要求：Bash 5+；内容替换依赖 perl（UTF-8）

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/knowledge-config.sh" ]]; then
  printf '错误: 缺少配置文件 %s\n' "$SCRIPT_DIR/knowledge-config.sh" >&2
  exit 1
fi

# shellcheck disable=SC1091
source "$SCRIPT_DIR/knowledge-config.sh"

log() { printf '%s\n' "$*" >&2; }
error() { log "错误: $*"; exit 1; }
warn() { log "警告: $*"; }
info() { log "信息: $*"; }

post_init_checklist_text() {
  cat <<'CHECKLIST'

拷贝后建议核对（以目标文档目录内 README、*_meta.yaml 为准）：
  [ ] application_meta.yaml（由 system_meta.yaml 重命名）与各目录 README 元数据链一致
  [ ] INDEX_GUIDE.md / APPLICATION_INDEX.md（原 SYSTEM_INDEX.md）内相对链接在目标工程可点击
  [ ] knowledge/、requirements/、changelogs/ 与各 *_meta.yaml 一致
  [ ] central 模式：本仓库 system/SYSTEM_INDEX.md「中央知识库接入工程」登记行与 applications/app-<APP>/APPNAME_manifest.yaml 是否反映当前工程与文档路径

CHECKLIST
}

print_post_init_checklist() {
  log ""
  if [[ -n "${DOCS_ABS:-}" ]]; then
    log "--- knowledge-init：拷贝后检查清单（目标: ${DOCS_ABS}） ---"
  else
    log "--- knowledge-init：拷贝后检查清单 ---"
  fi
  post_init_checklist_text >&2
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }
have_perl() { have_cmd perl; }

expand_user_path() {
  local p="$1"
  case "$p" in
    "~") echo "$HOME" ;;
    "~/"*) echo "$HOME/${p#~/}" ;;
    *) echo "$p" ;;
  esac
}

abs_path() {
  local p
  p="$(expand_user_path "$1")"
  if [[ "$p" != /* ]]; then
    p="$(pwd)/$p"
  fi
  if [[ -d "$p" ]]; then
    (cd "$p" && pwd)
  else
    echo "$p"
  fi
}

strip_trailing_slash() {
  local p="$1"
  while [[ "$p" != "/" && "$p" == */ ]]; do
    p="${p%/}"
  done
  echo "$p"
}

ensure_dir() {
  if [[ "${DRY_RUN:-0}" == "0" ]]; then
    mkdir -p "$1"
  fi
}

CONFLICT_PROMPT_MODE="${CONFLICT_PROMPT_MODE:-}"
BACKUP_ROOT="${BACKUP_ROOT:-}"

get_backup_root() {
  local base="${TARGET_DIR:-$PWD}/.knowledge-init"
  local stamp
  stamp="$(date +%Y-%m-%d_%H-%M-%S)"
  if [[ -n "${BACKUP_ROOT:-}" ]]; then
    echo "$BACKUP_ROOT"
    return 0
  fi
  BACKUP_ROOT="${base}/${stamp}"
  echo "$BACKUP_ROOT"
}

backup_existing_path() {
  local existing="$1"
  local backup_root
  backup_root="$(get_backup_root)"
  local rel
  if [[ -n "${TARGET_DIR:-}" && "$existing" == "$TARGET_DIR/"* ]]; then
    rel="${existing#"$TARGET_DIR"/}"
  else
    rel="${existing#/}"
  fi
  local backup_target="${backup_root}/${rel}"
  if [[ -e "$backup_target" ]]; then
    local i=1
    while [[ -e "${backup_target}.__${i}" ]]; do
      i=$((i+1))
    done
    backup_target="${backup_target}.__${i}"
  fi
  mkdir -p "$(dirname "$backup_target")" 2>/dev/null || true
  mv "$existing" "$backup_target"
  info "已备份：$existing -> $backup_target"
}

should_overwrite_existing() {
  local target="$1"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    return 0
  fi
  if [[ "${FORCE:-0}" == "1" ]]; then
    return 0
  fi
  case "${CONFLICT_PROMPT_MODE:-}" in
    overwrite_all) return 0 ;;
    skip_all) return 1 ;;
  esac
  if [[ ! -t 0 ]]; then
    return 0
  fi
  log "目标已存在：$target"
  printf '选择操作：覆盖(o) / 跳过(s) / 全部覆盖(a) / 全部跳过(b) [默认 o]： ' >&2
  local ans=""
  read -r ans || ans="o"
  case "$ans" in
    s|S) return 1 ;;
    a|A) CONFLICT_PROMPT_MODE="overwrite_all"; return 0 ;;
    b|B) CONFLICT_PROMPT_MODE="skip_all"; return 1 ;;
    o|O|"") return 0 ;;
    *) log "无效选择：$ans，默认覆盖"; return 0 ;;
  esac
}

copy_dir() {
  local src="$1" dst="$2"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[dry-run] 拷贝目录: $src -> $dst"
    return 0
  fi
  if [[ -e "$dst" ]]; then
    if ! should_overwrite_existing "$dst"; then
      log "[skip] 已存在目录，跳过：$dst"
      return 0
    fi
    backup_existing_path "$dst"
  fi
  ensure_dir "$(dirname "$dst")"
  ensure_dir "$dst"
  if have_cmd rsync; then
    rsync -a "$src"/ "$dst"/
  else
    cp -R "$src"/. "$dst"/
  fi
}

detect_git_repo_ref_or_empty() {
  local target="$1"
  if ! have_cmd git; then
    echo ""
    return 0
  fi
  if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local remote_url git_root
    remote_url="$(git -C "$target" config --get remote.origin.url 2>/dev/null || true)"
    if [[ -n "$remote_url" ]]; then
      echo "$remote_url"
      return 0
    fi
    git_root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ -n "$git_root" ]]; then
      echo "$(abs_path "$git_root")"
      return 0
    fi
    echo ""
    return 0
  fi
  echo ""
}

detect_git_root_path_or_empty() {
  local target="$1"
  if ! have_cmd git; then
    echo ""
    return 0
  fi
  if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local git_root
    git_root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ -n "$git_root" ]]; then
      echo "$(abs_path "$git_root")"
      return 0
    fi
  fi
  echo ""
}

docs_path_relative_to_git_root_or_abs() {
  local git_root="$1"
  local docs_abs="$2"
  if [[ -z "$git_root" ]]; then
    echo "$docs_abs"
    return 0
  fi
  git_root="$(strip_trailing_slash "$git_root")"
  docs_abs="$(strip_trailing_slash "$docs_abs")"
  case "$docs_abs" in
    "$git_root")
      echo "/"
      return 0
      ;;
    "$git_root"/*)
      local rel="${docs_abs#"$git_root"}"
      echo "$rel"
      return 0
      ;;
    *)
      echo "$docs_abs"
      return 0
      ;;
  esac
}

# 目标工程根相对文档目录路径，带尾斜杠（供正文将模板中的字面量 system/ 替换为实际文档前缀，默认常为 system/）
compute_docs_rel_slash() {
  local root="$1"
  local docs="$2"
  root="$(strip_trailing_slash "$root")"
  docs="$(strip_trailing_slash "$docs")"
  if [[ "$docs" == "$root" ]]; then
    printf '%s\n' "./"
    return 0
  fi
  if [[ "$docs" == "$root"/* ]]; then
    printf '%s\n' "${docs#"$root"/}/"
    return 0
  fi
  printf '%s\n' "$docs/"
}

# 路径各段文件名中的 system（不区分大小写）→ application
map_rel_path_system_to_application() {
  local rel="${1#./}"
  [[ -z "$rel" ]] && { echo ""; return 0; }
  local IFS='/'
  local -a parts
  read -ra parts <<< "$rel"
  local out="" sep=""
  local p newp
  for p in "${parts[@]}"; do
    [[ -z "$p" ]] && continue
    newp="$(perl -CSD -pe 's/SYSTEM_INDEX/APPLICATION_INDEX/gi; s/system/application/gi' <<< "$p")"
    out="${out}${sep}${newp}"
    sep="/"
  done
  printf '%s' "$out"
}

is_probably_text_file() {
  local f="$1"
  case "$f" in
    *.md|*.yaml|*.yml|*.json|*.jsonl|*.txt|*.sh|*.gitignore|SKILL.md|*.html|*.css|*.js|*.toml) return 0 ;;
  esac
  if have_cmd file; then
    local mt
    mt="$(file -b --mime-type "$f" 2>/dev/null || true)"
    [[ "$mt" == text/* || "$mt" == application/json || "$mt" == *yaml* || "$mt" == *json* ]] && return 0
  fi
  return 1
}

# 文档树：.ai/ → Agent 目录（带尾斜杠）；system/ → 目标文档目录相对路径（带尾斜杠）；
# 系统→应用；SYSTEM_INDEX / system_meta / 词界 system→application（须在 system/ 替换之后）
transform_file_content_for_docs() {
  local file="$1"
  local agent_slash="$2"
  local docs_slash="$3"
  [[ -f "$file" ]] || return 0
  is_probably_text_file "$file" || return 0
  have_perl || { warn "未安装 perl，跳过内容替换：$file"; return 0; }
  SDX_AGENT_SLASH="$agent_slash" SDX_DOCS_SLASH="$docs_slash" perl -CSD -i -pe '
    s{\.ai/}{$ENV{SDX_AGENT_SLASH}}g;
    s{system/}{$ENV{SDX_DOCS_SLASH}}gi;
    s{SYSTEM_INDEX}{APPLICATION_INDEX}gi;
    s{system_meta}{application_meta}gi;
    s{\bsystem\b}{application}gi;
    s{系统}{应用}g;
  ' "$file" 2>/dev/null || true
}

# Agent 树（skills/rules）：`.ai/` → Agent 目录；`system/` → 目标工程文档目录相对路径（见文件头步骤 2）
transform_file_content_for_agent_install() {
  local file="$1"
  local agent_slash="$2"
  local docs_slash="$3"
  [[ -f "$file" ]] || return 0
  is_probably_text_file "$file" || return 0
  have_perl || return 0
  SDX_AGENT_SLASH="$agent_slash" SDX_DOCS_SLASH="$docs_slash" perl -CSD -i -pe '
    s{\.ai/}{$ENV{SDX_AGENT_SLASH}}g;
    s{system/}{$ENV{SDX_DOCS_SLASH}}gi;
  ' "$file" 2>/dev/null || true
}

rewrite_tree_agent_install() {
  local root="$1"
  local agent_slash="$2"
  local docs_slash="$3"
  [[ -d "$root" ]] || return 0
  local f
  while IFS= read -r -d '' f; do
    transform_file_content_for_agent_install "$f" "$agent_slash" "$docs_slash"
  done < <(find "$root" -type f -print0 2>/dev/null || true)
}

copy_file() {
  local src="$1" dst="$2"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[dry-run] 拷贝文件: $src -> $dst"
    return 0
  fi
  if [[ -e "$dst" ]]; then
    if ! should_overwrite_existing "$dst"; then
      log "[skip] 已存在文件，跳过：$dst"
      return 0
    fi
    backup_existing_path "$dst"
  fi
  ensure_dir "$(dirname "$dst")"
  cp "$src" "$dst"
}

# 将 system/ 同步到目标文档目录（排除 DESIGN.md、CONTRIBUTING.md）；替换规则见文件头步骤 1
install_system_to_docs() {
  local src_root="$REPO_ROOT/system"
  local dst_root="$DOCS_ABS"
  local primary_agent_slash="$1"
  local docs_slash="$2"

  info ">>> 初始化 system/ → 目标文档目录..."
  info "  源: $src_root"
  info "  目标: $dst_root"
  info "  文档内 .ai/ → ${primary_agent_slash}（首个 Agent）；正文 system/ → ${docs_slash}"

  [[ -d "$src_root" ]] || error "未找到 $src_root"

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[dry-run] 遍历 ${src_root} -> ${dst_root}（排除 DESIGN.md、CONTRIBUTING.md）"
  fi

  local rel src_f dst_f base
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    [[ -z "$rel" ]] && continue
    base="${rel##*/}"
    if [[ "$base" == "DESIGN.md" || "$base" == "CONTRIBUTING.md" ]]; then
      continue
    fi
    src_f="$src_root/$rel"
    dst_f="$dst_root/$(map_rel_path_system_to_application "$rel")"
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
      log "[dry-run] 文件: $src_f -> $dst_f"
      continue
    fi
    if [[ -e "$dst_f" ]]; then
      if ! should_overwrite_existing "$dst_f"; then
        log "[skip] 已存在，跳过：$dst_f"
        continue
      fi
      backup_existing_path "$dst_f"
    fi
    ensure_dir "$(dirname "$dst_f")"
    cp "$src_f" "$dst_f"
    transform_file_content_for_docs "$dst_f" "$primary_agent_slash" "$docs_slash"
  done < <(cd "$src_root" && find . -type f -print0)

  info "  system/ 同步完成"
}

sync_rules_filtered() {
  local src_rules="$1"
  local dst_rules="$2"
  [[ -d "$src_rules" ]] || return 0
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[dry-run] 同步规则：$src_rules/ -> $dst_rules/"
  else
    ensure_dir "$dst_rules"
  fi
  local item base
  shopt -s nullglob
  for item in "$src_rules"/*; do
    base="$(basename "$item")"
    if [[ -d "$item" ]]; then
      if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[dry-run] 拷贝目录: $base -> $dst_rules/$base"
      else
        info "  [rules] 拷贝目录: $base -> $dst_rules/$base"
        copy_dir "$item" "$dst_rules/$base"
      fi
    else
      if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[dry-run] 拷贝文件: $base -> $dst_rules/$base"
      else
        info "  [rules] 拷贝文件: $base -> $dst_rules/$base"
        copy_file "$item" "$dst_rules/$base"
      fi
    fi
  done
}

install_agent_skills_and_rules() {
  local docs_slash="$1"
  local agent agent_dir agent_slash
  for agent in "${enabled_agents[@]}"; do
    agent_dir="$TARGET_DIR/$(sdx_get_agent_dir "$agent")"
    agent_slash="$(sdx_get_agent_dir "$agent")/"
    info ">>> 安装 ${agent} Agent 的 skills 与 rules..."
    info "  agent 目录: $agent_dir"
    info "  正文 .ai/ → ${agent_slash}；system/ → ${docs_slash}"

    ensure_dir "$agent_dir"
    ensure_dir "$agent_dir/skills"
    ensure_dir "$agent_dir/rules"

    shopt -s nullglob
    local sd skill
    local -a skill_dirs=()
    for sd in "$REPO_ROOT/.ai/skills"/*/; do
      [[ -d "$sd" ]] || continue
      skill="$(basename "$sd")"
      skill_dirs+=("$sd")
    done
    if [[ "${#skill_dirs[@]}" -eq 0 ]]; then
      warn "未找到 $REPO_ROOT/.ai/skills 下的技能子目录"
    else
      for sd in "${skill_dirs[@]}"; do
        skill="$(basename "$sd")"
        copy_dir "$sd" "$agent_dir/skills/$skill"
      done
    fi

    if [[ -f "$REPO_ROOT/.ai/skills/README.md" ]]; then
      copy_file "$REPO_ROOT/.ai/skills/README.md" "$agent_dir/skills/README.md"
    fi

    sync_rules_filtered "$REPO_ROOT/.ai/rules" "$agent_dir/rules"

    if [[ "${DRY_RUN:-0}" == "0" ]]; then
      rewrite_tree_agent_install "$agent_dir/skills" "$agent_slash" "$docs_slash"
      rewrite_tree_agent_install "$agent_dir/rules" "$agent_slash" "$docs_slash"
    fi
  done
}

usage() {
  cat <<'EOF'
用法: knowledge-init [选项] <目标工程文档目录>

说明:
  将本仓库 system/ 目录（排除 DESIGN.md、CONTRIBUTING.md）同步到目标工程的文档目录。
  文件名中 system（不区分大小写）替换为 application；正文内 .ai/ 替换为首个所选 Agent 目录（如 .cursor/）、
  正文中字面量 system/ 替换为相对工程根的文档路径（带尾斜杠；默认常用目录名为 system/）；另将英文词 system→application、中文「系统」→「应用」。
  同时将 .ai/skills 与 .ai/rules 安装到所选 Agent 目录；正文中 .ai/ 改为对应 Agent 路径，字面量 system/ 改为上述文档路径前缀。

  参数 <目标工程文档目录> 示例: ~/workspace/test/system（默认常用名为 system）
  工程根: 默认可自动创建（mkdir -p）<目标工程文档目录> 的父目录即工程根；若工程根已存在但不是目录则报错。
        文档子目录（如 system）若不存在，拷贝过程中会按需创建。
        使用 --no-create-root 可要求工程根必须事先存在（与旧行为一致）。

  模式:
  - standalone（默认）：仅目标工程落盘
  - central：注册应用到系统知识库（更新本仓库 system/SYSTEM_INDEX.md），并在 applications/app-<后缀>/ 建立应用知识库镜像与 APPNAME_manifest.yaml

选项:
  --mode=MODE         standalone（默认）| central（s | c）
  --app-id=APP-ID     中央模式下的 APP ID（默认由工程目录名推导为 APP-XXX）
  --agents=LIST       cursor|trea|claude|all，逗号分隔（默认: cursor）
  --no-create-root    不自动创建工程根（父目录须已存在）
  --force             强制覆盖（不提示）
  --dry-run           预览
  -h, --help          帮助

环境变量:
  REPO_ROOT                本仓库根（默认自动探测）
  CREATE_PROJECT_ROOT      是否自动创建工程根：1（默认）| 0（等同 --no-create-root）

拷贝后检查清单见下方。
EOF
  post_init_checklist_text
}

REPO_ROOT="${REPO_ROOT:-}"
MODE="${MODE:-standalone}"
DOCS_ABS=""
TARGET_DIR=""
APP_ID_OPT="${APP_ID_OPT:-}"
AGENTS_OPT="${AGENTS_OPT:-cursor}"
DRY_RUN="${DRY_RUN:-0}"
FORCE="${FORCE:-0}"
CREATE_PROJECT_ROOT="${CREATE_PROJECT_ROOT:-1}"

parse_args() {
  while (( $# > 0 )); do
    case "$1" in
      --mode=*)
        MODE="${1#*=}"
        shift
        ;;
      --mode)
        shift
        MODE="${1:-}"
        shift
        ;;
      --app-id=*)
        APP_ID_OPT="${1#*=}"
        shift
        ;;
      --app-id)
        shift
        APP_ID_OPT="${1:-}"
        shift
        ;;
      --agents=*)
        AGENTS_OPT="${1#*=}"
        shift
        ;;
      --agents)
        shift
        local parts=()
        while (( $# > 0 )); do
          case "$1" in
            -*) break ;;
            *) parts+=("$1"); shift ;;
          esac
        done
        if (( ${#parts[@]} == 0 )); then
          error "缺少 --agents 值（如 cursor,trea 或 cursor trea）"
        fi
        AGENTS_OPT="$(IFS=','; echo "${parts[*]}")"
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --force)
        FORCE=1
        shift
        ;;
      --no-create-root)
        CREATE_PROJECT_ROOT=0
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        error "未知选项: $1"
        ;;
      *)
        DOCS_ABS="$1"
        shift
        ;;
    esac
  done
}

declare -a enabled_agents=()

parse_agents() {
  if ! sdx_validate_agents "$AGENTS_OPT"; then
    error "无效 --agents: ${AGENTS_OPT}（支持 cursor、trea、claude、all 及逗号分隔组合）"
  fi
  read -ra enabled_agents <<< "$(sdx_normalize_agents "$AGENTS_OPT")"
  ((${#enabled_agents[@]} > 0)) || error "未解析到任何 Agent"
}

init_repo_root() {
  if [[ -z "$REPO_ROOT" ]]; then
    REPO_ROOT="$(abs_path "$SCRIPT_DIR/..")"
  fi
  [[ -d "$REPO_ROOT/system" ]] || error "未找到 system 目录: $REPO_ROOT/system"
  [[ -d "$REPO_ROOT/.ai/skills" ]] || error "未找到 .ai/skills: $REPO_ROOT/.ai/skills"
  [[ -d "$REPO_ROOT/.ai/rules" ]] || error "未找到 .ai/rules: $REPO_ROOT/.ai/rules"
}

validate() {
  [[ -n "$DOCS_ABS" ]] || { usage; exit 2; }
  DOCS_ABS="$(strip_trailing_slash "$(abs_path "$DOCS_ABS")")"
  TARGET_DIR="$(abs_path "$(dirname "$DOCS_ABS")")"
  if [[ -e "$TARGET_DIR" && ! -d "$TARGET_DIR" ]]; then
    error "目标工程路径已存在但不是目录: ${TARGET_DIR}"
  fi
  if [[ ! -d "$TARGET_DIR" ]]; then
    if [[ "${CREATE_PROJECT_ROOT}" == "1" ]]; then
      if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[dry-run] 将创建工程根目录: ${TARGET_DIR}"
      else
        mkdir -p "$TARGET_DIR"
        info "已创建工程根目录: ${TARGET_DIR}"
      fi
    else
      error "目标工程目录不存在: ${TARGET_DIR}（请事先创建工程根，或去掉 --no-create-root / 设置 CREATE_PROJECT_ROOT=1）"
    fi
  fi
  case "$MODE" in
    standalone|s) MODE="standalone" ;;
    central|c) MODE="central" ;;
    *) error "无效模式: ${MODE}（standalone/central 或 s/c）" ;;
  esac
}

resolve_central_app_id_and_slug() {
  local project_name
  project_name="$(basename "$TARGET_DIR")"
  if [[ -n "$APP_ID_OPT" ]]; then
    CENTRAL_APP_ID="$APP_ID_OPT"
  else
    CENTRAL_APP_ID="$(sdx_sanitize_app_id "$project_name")"
  fi
  CENTRAL_APP_SLUG="${CENTRAL_APP_ID#APP-}"
  [[ -n "$CENTRAL_APP_SLUG" ]] || CENTRAL_APP_SLUG="APPNAME"
}

ensure_central_app_mirror() {
  local tmpl="$REPO_ROOT/applications/app-APPNAME"
  local dest="$REPO_ROOT/applications/app-${CENTRAL_APP_SLUG}"
  local project_name
  project_name="$(basename "$TARGET_DIR")"

  [[ -d "$tmpl" ]] || error "未找到联邦模板目录: $tmpl"

  info ">>> 中央模式：建立应用知识库镜像..."
  info "  目录: $dest"
  info "  APP ID: $CENTRAL_APP_ID"

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[dry-run] 创建镜像: $tmpl -> $dest"
    return 0
  fi

  ensure_dir "$dest"

  if [[ -f "$tmpl/APPNAME_manifest.yaml" ]]; then
    copy_file "$tmpl/APPNAME_manifest.yaml" "$dest/APPNAME_manifest.yaml"
    if have_perl && [[ -f "$dest/APPNAME_manifest.yaml" ]]; then
      SDX_MF_SLUG="$CENTRAL_APP_SLUG" SDX_MF_PN="$project_name" SDX_MF_AID="$CENTRAL_APP_ID" \
        perl -i -CSD -pe '
          s/^template_id:.*/template_id: app-$ENV{SDX_MF_SLUG}/;
          s/^description:.*/description: 联邦单元 $ENV{SDX_MF_PN}（$ENV{SDX_MF_AID}），由 knowledge-init central 模式生成/;
        ' "$dest/APPNAME_manifest.yaml" 2>/dev/null || true
    fi
  fi

  if [[ -f "$tmpl/README.md" ]]; then
    copy_file "$tmpl/README.md" "$dest/README.md"
    if have_perl && [[ -f "$dest/README.md" ]]; then
      perl -i -CSD -pe "
        s/applications\\/app-APPNAME/applications\\/app-${CENTRAL_APP_SLUG}/g;
        s/app-APPNAME/app-${CENTRAL_APP_SLUG}/g;
      " "$dest/README.md" 2>/dev/null || true
    fi
  fi

  info "  镜像初始化完成（含 APPNAME_manifest.yaml）"
}

upsert_system_index_record() {
  local app_id="$1" repo_or_path="$2" docs_abs="$3"
  local idx="$REPO_ROOT/system/SYSTEM_INDEX.md"
  [[ -f "$idx" ]] || error "未找到 system/SYSTEM_INDEX.md: $idx"

  local marker_start="## 五、中央知识库接入工程"
  local marker_table_header="| APP ID | 工程路径（Git 或绝对路径） | 文档目录 |"
  local marker_table_sep="|--------|---------------------------|----------|"
  local row="| ${app_id} | ${repo_or_path} | ${docs_abs} |"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] 更新索引登记: $idx"
    log "[dry-run] 追加/替换行: $row"
    return 0
  fi

  if ! grep -qF "$marker_start" "$idx"; then
    {
      printf '\n'
      printf '%s\n\n' "$marker_start"
      printf '%s\n' "本节用于在本仓库（中央知识库）登记各目标工程的接入信息，便于追溯与映射。"
      printf '\n'
      printf '%s\n' "$marker_table_header"
      printf '%s\n' "$marker_table_sep"
      printf '%s\n' "$row"
      printf '\n'
    } >> "$idx"
    return 0
  fi

  if grep -qF "| ${app_id} |" "$idx"; then
    local tmp="${idx}.tmp"
    awk -v app="| ${app_id} |" -v newline="$row" '
      index($0, app)==1 { print newline; next }
      { print }
    ' "$idx" > "$tmp"
    mv "$tmp" "$idx"
    return 0
  fi

  local tmp="${idx}.tmp"
  awk -v header="$marker_table_header" -v sep="$marker_table_sep" -v newline="$row" '
    { print }
    $0==sep { print newline }
  ' "$idx" > "$tmp"
  mv "$tmp" "$idx"
}

ensure_central_registration() {
  local repo_ref git_root repo_or_path docs_manifest_path
  repo_ref="$(detect_git_repo_ref_or_empty "$TARGET_DIR")"
  git_root="$(detect_git_root_path_or_empty "$TARGET_DIR")"
  if [[ -n "$repo_ref" ]]; then
    repo_or_path="$repo_ref"
  else
    repo_or_path="$TARGET_DIR"
  fi
  docs_manifest_path="$(docs_path_relative_to_git_root_or_abs "$git_root" "$DOCS_ABS")"

  info ">>> 中央模式：登记应用到系统知识库索引..."
  info "  APP ID: $CENTRAL_APP_ID"
  info "  工程: $repo_or_path"
  info "  文档目录: $DOCS_ABS"

  upsert_system_index_record "$CENTRAL_APP_ID" "$repo_or_path" "$DOCS_ABS"
}

main() {
  parse_args "$@"
  init_repo_root
  validate
  parse_agents

  local primary_agent_slash docs_slash
  primary_agent_slash="$(sdx_get_agent_dir "${enabled_agents[0]}")/"
  docs_slash="$(compute_docs_rel_slash "$TARGET_DIR" "$DOCS_ABS")"
  have_perl || warn "未检测到 perl：文档与 Agent 文件中的占位替换可能不完整，建议安装 perl。"

  install_system_to_docs "$primary_agent_slash" "$docs_slash"
  if [[ "$MODE" == "central" ]]; then
    resolve_central_app_id_and_slug
    ensure_central_registration
    ensure_central_app_mirror
  fi

  install_agent_skills_and_rules "$docs_slash"

  info "完成：knowledge-init"
  print_post_init_checklist
}

main "$@"
