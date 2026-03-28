#!/usr/bin/env bash
# knowledge-init：将应用知识库根目录模板（applications/app-APPNAME）初始化到目标工程文档目录
# 运行要求：Bash 5+

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/knowledge-config.sh" ]]; then
  printf '错误: 缺少配置文件 %s\n' "$SCRIPT_DIR/knowledge-config.sh" >&2
  exit 1
fi

# shellcheck disable=SC1091
source "$SCRIPT_DIR/knowledge-config.sh"
sdx_require_bash5

log() { printf '%s\n' "$*" >&2; }
error() { log "错误: $*"; exit 1; }
warn() { log "警告: $*"; }
info() { log "信息: $*"; }

# 拷贝模板后的建议核对项（与 applications/app-APPNAME 内 README / *_meta.yaml 约定一致）
post_init_checklist_text() {
  cat <<'CHECKLIST'

拷贝后建议核对（以目标文档目录内 README、*_meta.yaml 为准；字段含义以 YAML 为 SSOT）：
  [ ] application_meta.yaml 已随模板落地；若实际目录名不再是 app-APPNAME，可酌情更新其中 template_directory 或描述，避免误导 Agent
  [ ] INDEX_GUIDE.md（或 PROJECT_INDEX.md 短入口 / 仓库约定的根 Index Guide）、README.md 内相对链接在目标工程中可访问
  [ ] knowledge/knowledge_meta.yaml、requirements/requirements_meta.yaml、changelogs/changelogs_meta.yaml 与各目录 README 首段「元数据」链一致
  [ ] knowledge/constitution/：principles_meta.yaml、standards_meta.yaml、adr/adr_meta.yaml（若存在）与 constitution/README.md 组件表互链
  [ ] 正式需求包：自 REQUIREMENT-EXAMPLE 复制为 REQUIREMENT-{ID}/；REQUIREMENT-EXAMPLE 为结构示例，不单建 *_meta.yaml（见 requirements/README.md）
  [ ] central 模式：核对本仓库 system/SYSTEM_INDEX.md 接入登记行与 system/knowledge/technical/.../APP-*.yaml 是否反映当前工程与文档路径

CHECKLIST
}

print_post_init_checklist() {
  log ""
  if [[ -n "${DOCS_ABS:-}" ]]; then
    # 使用 ${DOCS_ABS} 明确变量边界：避免 bash 在 UTF-8 全角括号等紧邻字符时误解析变量名
    log "--- knowledge-init：拷贝后检查清单（目标: ${DOCS_ABS}） ---"
  else
    log "--- knowledge-init：拷贝后检查清单 ---"
  fi
  post_init_checklist_text >&2
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

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

# 处理“目标已存在”的冲突：询问覆盖/跳过，并在覆盖时将原路径备份到目录中。
# 交互规则：
# - 交互终端（stdin 是 TTY）且未设置 --force 时：询问 o 覆盖 / s 跳过 / a 全部覆盖 / b 全部跳过
# - 非交互场景或已设置 --force：默认覆盖（但仍会备份旧内容，除非 DRY_RUN=1）
CONFLICT_PROMPT_MODE="${CONFLICT_PROMPT_MODE:-}"  # overwrite_all | skip_all
BACKUP_ROOT="${BACKUP_ROOT:-}" # set on demand

get_backup_root() {
  # 备份根目录：按“年月日”聚合
  local base="${TARGET_DIR:-$PWD}/.knowledge-init"
  local stamp
  # 用“年月日_时分秒”且避免使用 ":" 以保证在常见文件系统可用
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

  # 将备份内容按“原始相对路径”保留层级放入备份根目录：
  # 目标工程下：
  #   - 原 $TARGET_DIR/.cursor/rules/...  => 备份到 $TARGET_DIR/.knowledge-init/年月日时分秒/.cursor/rules/...
  #   - 原 $TARGET_DIR/docs/...          => 备份到 $TARGET_DIR/.knowledge-init/年月日时分秒/docs/...
  # 这样既满足按原目录结构备份，也避免把整个 docs 目录 mv 到其子目录内导致递归失败。
  local rel
  if [[ -n "${TARGET_DIR:-}" && "$existing" == "$TARGET_DIR/"* ]]; then
    rel="${existing#"$TARGET_DIR"/}"
  else
    rel="${existing#/}"
  fi

  local backup_target="${backup_root}/${rel}"

  # 同一天重复运行时，保证不会覆盖已有备份（添加递增后缀）
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

  # 非交互环境：保持“默认覆盖”的兼容行为
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

sanitize_app_id() {
  # 从目录名推导 APP ID：大写，非字母数字转 -
  local raw="$1"
  raw="${raw##*/}"
  raw="$(echo "$raw" | tr '[:lower:]' '[:upper:]')"
  raw="$(echo "$raw" | sed -E 's/[^A-Z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')"
  if [[ -z "$raw" ]]; then
    echo "APP-APPNAME"
  else
    echo "APP-$raw"
  fi
}

detect_git_repo_ref_or_empty() {
  local target="$1"
  if ! have_cmd git; then
    echo ""
    return 0
  fi
  if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # 优先使用远端仓库地址（更符合 repo_url 语义）；缺失时退回到本地仓库根目录
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
      # rel 以 "/" 开头，符合现有 docs_manifest_path 约定（如 /docs/manifest.yaml）
      echo "$rel"
      return 0
      ;;
    *)
      echo "$docs_abs"
      return 0
      ;;
  esac
}

usage() {
  cat <<'EOF'
用法: knowledge-init [选项] <目标工程文档目录>

说明:
  将本仓库应用知识库根目录模板（applications/app-APPNAME/）下所有目录和文件，拷贝到目标工程的文档目录下。

  参数 <目标工程文档目录> 示例:
    ~/workspace/test/docs
  其中：
    - 目标工程为 ~/workspace/test
    - 文档目录为 docs（即目标工程下的 docs 目录）

  两种模式:
  - standalone（默认）：仅对目标工程做拷贝
  - central：在本仓库 system/SYSTEM_INDEX.md 记录目标工程路径与文档目录，并在 system/knowledge/technical/SYS-ECOMMERCE-BACKEND/ 下新建 APP-<工程名>/ 模板

选项:
  --mode=MODE         模式：standalone（默认）| central（也支持缩写：s | c）
  --app-id=APP-ID     中央模式下写入技术视角的 APP ID（默认由工程目录推导）
  --agents=LIST      Agent 列表（支持多选）：cursor|trea|all，且可用逗号分隔如 cursor,trea（默认: cursor）
  --force             强制覆盖已存在内容（不提示）；未设置时若目标已存在将提示覆盖/跳过
  --dry-run           预览模式（不落盘）
  -h, --help          显示帮助

环境变量:
  REPO_ROOT           本仓库根目录（默认自动探测）

拷贝后检查清单:
  成功执行后（含 --dry-run 预览结束）终端会输出建议核对项；完整列表见下方。
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
  if [[ "$AGENTS_OPT" == "all" ]]; then
    enabled_agents=("${SDX_SUPPORTED_AGENTS[@]}")
    return 0
  fi

  IFS=',' read -ra enabled_agents <<< "$AGENTS_OPT"
  local a
  for a in "${enabled_agents[@]}"; do
    [[ "$a" == "cursor" || "$a" == "trea" ]] || error "无效 agent: $a（只支持 cursor、trea、all）"
  done
}

init_repo_root() {
  if [[ -z "$REPO_ROOT" ]]; then
    REPO_ROOT="$(abs_path "$SCRIPT_DIR/..")"
  fi
  [[ -d "$REPO_ROOT/applications/app-APPNAME" ]] || error "未找到应用知识库根目录模板: $REPO_ROOT/applications/app-APPNAME"
  [[ -d "$REPO_ROOT/system" ]] || error "未找到 system 目录: $REPO_ROOT/system"
}

validate() {
  [[ -n "$DOCS_ABS" ]] || { usage; exit 2; }

  DOCS_ABS="$(strip_trailing_slash "$(abs_path "$DOCS_ABS")")"
  TARGET_DIR="$(abs_path "$(dirname "$DOCS_ABS")")"
  if [[ ! -d "$TARGET_DIR" ]]; then
    info "目标工程目录不存在，将创建: $TARGET_DIR"
    ensure_dir "$TARGET_DIR"
  fi

  case "$MODE" in
    standalone|s) MODE="standalone" ;;
    central|c) MODE="central" ;;
    *) error "无效模式: $MODE（必须是 standalone/central 或 s/c）" ;;
  esac
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

install_agent_skills_and_rules() {
  local agent agent_dir
  for agent in "${enabled_agents[@]}"; do
    case "$agent" in
      cursor) agent_dir="$TARGET_DIR/.cursor" ;;
      trea)   agent_dir="$TARGET_DIR/.trea" ;;
      *) error "未知 agent: $agent" ;;
    esac

    info ">>> 安装 ${agent} Agent 的 skills 与 rules..."
    info "  agent 目录: $agent_dir"

    ensure_dir "$agent_dir"
    ensure_dir "$agent_dir/skills"
    ensure_dir "$agent_dir/rules"

    # skills：只安装 agent-* / document-* / knowledge-*，默认不安装 sdx-*
    shopt -s nullglob
    local -a skill_dirs=()
    skill_dirs+=("$REPO_ROOT/.ai/skills"/agent-*)
    skill_dirs+=("$REPO_ROOT/.ai/skills"/document-*)
    skill_dirs+=("$REPO_ROOT/.ai/skills"/knowledge-*)
    if [[ "${#skill_dirs[@]}" -eq 0 ]]; then
      warn "未找到匹配的 skills（agent-*/document-*/knowledge-*）"
    else
      local sd
      for sd in "${skill_dirs[@]}"; do
        local skill
        skill="$(basename "$sd")"
        copy_dir "$sd" "$agent_dir/skills/$skill"
      done
    fi

    # 将 skills 的说明文件拷贝到 agent 的 skills 根目录
    if [[ -f "$REPO_ROOT/.ai/skills/README.md" ]]; then
      copy_file "$REPO_ROOT/.ai/skills/README.md" "$agent_dir/skills/README.md"
    fi
    # rules：按用户要求同时拷贝到 agent/rules，便于就近查阅
    sync_rules_filtered "$REPO_ROOT/.ai/rules" "$agent_dir/rules"
  done
}

sync_dir_contents() {
  local src="$1" dst="$2"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[dry-run] 同步目录内容: $src/ -> $dst/"
    return 0
  fi

  # 仅在目标目录“非空”时才认为发生冲突（空目录无需备份）
  if [[ -d "$dst" ]] && [[ -n "$(ls -A "$dst" 2>/dev/null || true)" ]]; then
    if ! should_overwrite_existing "$dst"; then
      log "[skip] 已存在且非空目录，跳过：$dst"
      return 0
    fi
    backup_existing_path "$dst"
  fi

  ensure_dir "$dst"
  if have_cmd rsync; then
    rsync -a "$src"/ "$dst"/
  else
    cp -R "$src"/. "$dst"/
  fi
}

sync_rules_filtered() {
  # 逐个拷贝 rules 目录下文件或目录到目标工程对应 agent 的 rules
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

copy_app_template() {
  info ">>> 初始化应用知识库到目标工程..."
  info "  目标工程: $TARGET_DIR"
  info "  文档目录: $DOCS_ABS"

  ensure_dir "$DOCS_ABS"
  sync_dir_contents "$REPO_ROOT/applications/app-APPNAME" "$DOCS_ABS"
  info "  拷贝完成"
}

ensure_central_app_template() {
  local project_name app_id app_dir app_yaml docs_abs repo_or_path repo_ref git_root docs_manifest_path
  project_name="$(basename "$TARGET_DIR")"
  if [[ -n "$APP_ID_OPT" ]]; then
    app_id="$APP_ID_OPT"
  else
    app_id="$(sanitize_app_id "$project_name")"
  fi

  app_dir="$REPO_ROOT/system/knowledge/technical/SYS-ECOMMERCE-BACKEND/${app_id}"
  app_yaml="$app_dir/${app_id}.yaml"
  docs_abs="$DOCS_ABS"

  repo_ref="$(detect_git_repo_ref_or_empty "$TARGET_DIR")"
  git_root="$(detect_git_root_path_or_empty "$TARGET_DIR")"
  if [[ -n "$repo_ref" ]]; then
    repo_or_path="$repo_ref"
  else
    repo_or_path="$TARGET_DIR"
  fi
  docs_manifest_path="$(docs_path_relative_to_git_root_or_abs "$git_root" "$docs_abs")"

  info ">>> 中央知识库模式：登记并生成技术视角模板..."
  info "  APP ID: $app_id"
  info "  工程记录: $repo_or_path"
  info "  文档目录: $docs_abs"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] 创建目录: $app_dir"
    log "[dry-run] 写入文件: $app_yaml"
  else
    mkdir -p "$app_dir"
    # 始终写入（模板应反映最新接入信息）
    cat > "$app_yaml" <<EOF
# ${app_id} 应用注册信息
id: "${app_id}"
name: "${project_name}"
description: "由 knowledge-init 生成的应用注册模板"
repo_url: "${repo_or_path}"
docs_manifest_path: "${docs_manifest_path}"
service_ids: []
EOF
  fi

  upsert_system_index_record "$app_id" "$repo_or_path" "$docs_abs"
  info "  中央模式处理完成"
}

upsert_system_index_record() {
  local app_id="$1" repo_or_path="$2" docs_abs="$3"
  local idx="$REPO_ROOT/system/SYSTEM_INDEX.md"
  [[ -f "$idx" ]] || error "未找到 system/SYSTEM_INDEX.md: $idx"

  local marker_start="## 六、中央知识库接入工程"
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

main() {
  parse_args "$@"
  init_repo_root
  validate

  copy_app_template
  if [[ "$MODE" == "central" ]]; then
    ensure_central_app_template
  fi

  parse_agents
  install_agent_skills_and_rules

  info "完成：knowledge-init"
  print_post_init_checklist
}

main "$@"

