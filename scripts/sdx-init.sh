#!/usr/bin/env bash
# sdx-init：从 ai-sdd-docs 仓库初始化 SDD 开发环境
# 运行要求：Bash 5+

set -euo pipefail

# ============================================================================
# 配置与常量
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/sdx-config.sh" ]]; then
    printf '错误: 缺少配置文件 %s\n' "$SCRIPT_DIR/sdx-config.sh" >&2
    exit 1
fi

# shellcheck disable=SC1091
source "$SCRIPT_DIR/sdx-config.sh"
sdx_require_bash5

readonly SUPPORTED_AGENTS=("${SDX_SUPPORTED_AGENTS[@]}")
readonly DEFAULT_SKILLS=("${SDX_DEFAULT_SKILLS[@]}")

# 配置变量
REPO_ROOT="${REPO_ROOT:-}"
TARGET_DIR="${TARGET_DIR:-$(pwd)}"
DOCS_DIR="${DOCS_DIR:-${SDX_DEFAULTS[DOCS_DIR]}}"
SDX_MODE="${SDX_MODE:-${SDX_DEFAULTS[SDX_MODE]}}"
AI_DIR="${AI_DIR:-${SDX_DEFAULTS[AI_DIR]}}"
SKILLS_OPT="${SKILLS_OPT:-}"
DRY_RUN="${DRY_RUN:-0}"
FORCE="${FORCE:-0}"
AGENTS_OPT="${AGENTS_OPT:-${SDX_DEFAULTS[AGENTS_OPT]}}"
DOCS_SCOPE="${DOCS_SCOPE:-${SDX_DEFAULTS[DOCS_SCOPE]}}"
AI_RULES_SCOPE="${AI_RULES_SCOPE:-${SDX_DEFAULTS[AI_RULES_SCOPE]}}"

# 计算路径变量（在 init_paths 中设置）
SYSTEM_DOCS_ABS=""
APPS_ABS=""
AI_ABS=""
CURSOR_ABS=""
TREA_ABS=""

declare -a skip_paths=()
declare -a enabled_agents=()
declare -a install_skills=()

# ============================================================================
# 工具函数
# ============================================================================

# 日志函数
log() { echo "$*" >&2; }
error() { log "错误: $*"; exit 1; }
warn() { log "警告: $*"; }
info() { log "信息: $*"; }
dry_run() {
    if [[ "$DRY_RUN" == "1" ]]; then
        log "[dry-run] $*"
    fi
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

assert_valid() {
    local value="$1"
    local validator="$2"
    local label="$3"
    local expected="$4"

    if ! "$validator" "$value"; then
        error "无效${label}: ${value}，必须是 ${expected}"
    fi
}

# 路径工具
expand_user_path() {
    # 将以 ~ 开头的路径展开为 $HOME（注意：~ 在变量里不会自动展开）
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
        # dry-run 或目标目录尚未创建时允许不存在
        echo "$p"
    fi
}
ensure_dir() {
    if [[ "$DRY_RUN" == "0" ]]; then
        mkdir -p "$1"
    fi
}

# 安全拷贝
copy() {
    local src="$1" dst="$2"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        dry_run "拷贝: $src -> $dst"
        return 0
    fi
    
    ensure_dir "$(dirname "$dst")"
    
    if [[ -d "$src" && -d "$dst" ]]; then
        if have_cmd rsync; then
            rsync -a "$src"/ "$dst"/
        else
            cp -R "$src"/. "$dst"/
        fi
    else
        if [[ -e "$dst" ]]; then
            rm -rf "$dst"
        fi
        cp -R "$src" "$dst"
    fi
}

sync_dir_contents() {
    local src="$1" dst="$2"
    [[ -d "$src" ]] || return 0
    if [[ "$DRY_RUN" == "1" ]]; then
        dry_run "同步目录内容: $src/ -> $dst/"
        return 0
    fi
    ensure_dir "$dst"
    if have_cmd rsync; then
        rsync -a "$src"/ "$dst"/
    else
        cp -R "$src"/. "$dst"/
    fi
}

# 检查是否跳过路径
should_skip() {
    local path="$1"
    local p
    for p in "${skip_paths[@]:-}"; do
        [[ "$p" == "$path" ]] && return 0
    done
    return 1
}

# ============================================================================
# 参数解析
# ============================================================================

usage() {
    cat <<'EOF'
用法: sdx-init [选项] [目标目录]

从 ai-sdd-docs 仓库初始化 SDD 开发环境

运行要求: Bash 5+

选项:
  --mode=MODE         初始化模式：standalone（默认）| federation
  --dd=DIR            文档目录（默认: docs）
  --ds=SCOPE          文档范围：knowledge（默认）| full
  --ad=DIR            AI 配置目录（默认: .ai）
  --as=SCOPE          AI 规则范围：no-solution-analysis（默认）| full
  --agents=LIST       Agent 列表，逗号分隔或 all（默认: cursor）
  --skills=LIST       技能列表，逗号分隔或 all
  --force             强制覆盖
  --dry-run           预览模式
  -h, --help          显示帮助

环境变量:
  REPO_ROOT           仓库根目录
  TARGET_DIR          目标目录
  SDX_MODE            初始化模式
  DRY_RUN=1           启用预览模式
EOF
}

parse_args() {
    while (( $# > 0 )); do
        case "$1" in
            --mode=*)         SDX_MODE="${1#*=}" ;;
            --mode)           shift; SDX_MODE="${1:-}";;
            --dd=*)           DOCS_DIR="${1#*=}" ;;
            --dd)             shift; DOCS_DIR="${1:-}";;
            --ds=*)           DOCS_SCOPE="${1#*=}" ;;
            --ds)             shift; DOCS_SCOPE="${1:-}";;
            --ad=*)           AI_DIR="${1#*=}" ;;
            --ad)             shift; AI_DIR="${1:-}";;
            --as=*)           AI_RULES_SCOPE="${1#*=}" ;;
            --as)             shift; AI_RULES_SCOPE="${1:-}";;
            --agents=*)       AGENTS_OPT="${1#*=}" ;;
            --agents)         shift; AGENTS_OPT="${1:-}";;
            --skills=*)       SKILLS_OPT="${1#*=}" ;;
            --skills)         shift; SKILLS_OPT="${1:-}";;
            --force)          FORCE=1 ;;
            --dry-run)        DRY_RUN=1 ;;
            -h|--help)        usage; exit 0 ;;
            -*)               error "未知选项: $1" ;;
            *)                TARGET_DIR="$1" ;;
        esac
        shift
    done
}

validate_inputs() {
    assert_valid "$SDX_MODE" sdx_validate_mode "模式" "standalone 或 federation"
    assert_valid "$DOCS_SCOPE" sdx_validate_docs_scope "文档范围" "knowledge 或 full"
    assert_valid "$AI_RULES_SCOPE" sdx_validate_ai_rules_scope "AI 规则范围" "no-solution-analysis 或 full"
}

# ============================================================================
# 初始化与验证
# ============================================================================

init_repo() {
    if [[ -z "$REPO_ROOT" ]]; then
        REPO_ROOT="$(abs_path "$SCRIPT_DIR/..")"
        if [[ ! -d "$REPO_ROOT/.ai" ]]; then
            error "无法找到仓库根目录，请设置 REPO_ROOT 环境变量"
        fi
    fi
    
    if [[ ! -d "$REPO_ROOT" ]]; then
        error "仓库目录不存在: $REPO_ROOT"
    fi
}

init_paths() {
    TARGET_DIR="$(expand_user_path "$TARGET_DIR")"
    ensure_dir "$TARGET_DIR"
    TARGET_DIR="$(abs_path "$TARGET_DIR")"
    
    # 计算文档系统路径：docs_dir/system
    local system_docs_dir="$DOCS_DIR/system"
    local docs_root="$DOCS_DIR"
    local apps_dir
    if [[ "$SDX_MODE" == "federation" ]]; then
        apps_dir="$docs_root/applications"
    else
        apps_dir="$docs_root/application"
    fi
    
    # 设置绝对路径
    SYSTEM_DOCS_ABS="$TARGET_DIR/$system_docs_dir"
    APPS_ABS="$TARGET_DIR/$apps_dir"
    AI_ABS="$TARGET_DIR/$AI_DIR"
    CURSOR_ABS="$TARGET_DIR/.cursor"
    TREA_ABS="$TARGET_DIR/.trea"
}

discover_skills() {
    local all_skills=() default_skills=()
    local skill_prefixes=("${SDX_DEFAULT_SKILL_PREFIXES[@]}")
    
    if [[ -d "$REPO_ROOT/.ai/skills" ]]; then
        local -a skill_dirs=()
        local skilldir
        mapfile -d '' -t skill_dirs < <(find "$REPO_ROOT/.ai/skills" -mindepth 1 -maxdepth 1 -type d -print0)
        for skilldir in "${skill_dirs[@]}"; do
            local skill="$(basename "$skilldir")"
            all_skills+=("$skill")
            if [[ ! "$skill" =~ ^sdx- ]]; then
                local prefix
                for prefix in "${skill_prefixes[@]}"; do
                    if [[ "$skill" == "$prefix"* ]]; then
                        default_skills+=("$skill")
                        break
                    fi
                done
            fi
        done
    fi
    
    # 若无匹配技能，使用默认列表
    if [[ ${#default_skills[@]} -eq 0 ]]; then
        default_skills=("${DEFAULT_SKILLS[@]}")
    fi
    
    ALL_SKILLS="${all_skills[*]}"
    DEFAULT_SKILLS_LIST="${default_skills[*]}"
}

parse_agents() {
    if [[ "$AGENTS_OPT" == "all" ]]; then
        for agent in "${SUPPORTED_AGENTS[@]}"; do
            if [[ "$agent" == "cursor" || -d "$REPO_ROOT/.$agent" ]]; then
                enabled_agents+=("$agent")
            fi
        done
    else
        IFS=',' read -ra enabled_agents <<< "$AGENTS_OPT"
    fi
}

parse_skills() {
    if [[ -n "$SKILLS_OPT" ]]; then
        if [[ "$SKILLS_OPT" == "all" ]]; then
            IFS=' ' read -ra install_skills <<< "$ALL_SKILLS"
        else
            IFS=',' read -ra install_skills <<< "$SKILLS_OPT"
        fi
    else
        IFS=' ' read -ra install_skills <<< "$DEFAULT_SKILLS_LIST"
    fi
}

# ============================================================================
# 覆盖检查
# ============================================================================

check_overwrites() {
    local existing=()
    
    # 收集已存在的路径
    for path in "$SYSTEM_DOCS_ABS" "$APPS_ABS" "$AI_ABS"; do
        if [[ -e "$path" ]]; then
            existing+=("$path")
        fi
    done
    
    for agent in "${enabled_agents[@]}"; do
        local agent_path
        case "$agent" in
            cursor) agent_path="$CURSOR_ABS" ;;
            trea)   agent_path="$TREA_ABS" ;;
            *)      agent_path="$TARGET_DIR/.$agent" ;;
        esac
        if [[ -e "$agent_path" ]]; then
            existing+=("$agent_path")
        fi
    done
    
    (( ${#existing[@]} == 0 )) && return 0
    
    handle_existing "${existing[@]}"
}

handle_existing() {
    local existing=("$@")
    
    if [[ "$DRY_RUN" == "1" ]]; then
        dry_run "以下路径已存在，执行时将覆盖："
        printf '  - %s\n' "${existing[@]}"
        return 0
    fi
    
    if [[ -t 0 ]]; then
        info "以下路径已存在："
        printf '  - %s\n' "${existing[@]}"
        read -p "覆盖所有(y) / 跳过所有(n) [y/N]: " -r reply
        case "$reply" in
            [yY]*) ;;
            *) skip_paths=("${existing[@]}"); info "已跳过覆盖，继续其余操作。" ;;
        esac
    elif [[ "$FORCE" != "1" ]]; then
        error "路径已存在且非交互模式，请使用 --force 或先清理路径"
    fi
}

# ============================================================================
# 核心功能
# ============================================================================

copy_docs() {
    info ">>> 拷贝文档与知识库..."
    
    should_skip "$SYSTEM_DOCS_ABS" && { info "  跳过文档拷贝"; return 0; }
    
    ensure_dir "$SYSTEM_DOCS_ABS"
    
    # 拷贝 README
    if [[ -f "$REPO_ROOT/README.md" ]]; then
        copy "$REPO_ROOT/README.md" "$SYSTEM_DOCS_ABS/README.md"
    fi
    
    copy_system
    copy_apps
    handle_git
    
    info "  文档拷贝完成"
}

copy_system() {
    local system_dir="$REPO_ROOT/system"
    if [[ ! -d "$system_dir" ]]; then
        warn "无 system 目录"
        return 0
    fi
    
    local -a system_items=() system_files=()
    local item
    if [[ "$DOCS_SCOPE" == "full" ]]; then
        # 完整拷贝
        mapfile -d '' -t system_items < <(find "$system_dir" -mindepth 1 -maxdepth 1 -print0)
        for item in "${system_items[@]}"; do
            copy "$item" "$SYSTEM_DOCS_ABS/$(basename "$item")"
        done
    else
        # 仅拷贝 knowledge 和文件
        if [[ -d "$system_dir/knowledge" ]]; then
            copy "$system_dir/knowledge" "$SYSTEM_DOCS_ABS/knowledge"
        fi
        mapfile -d '' -t system_files < <(find "$system_dir" -mindepth 1 -maxdepth 1 -type f -print0)
        for item in "${system_files[@]}"; do
            copy "$item" "$SYSTEM_DOCS_ABS/$(basename "$item")"
        done
    fi
}

copy_apps() {
    should_skip "$APPS_ABS" && { info "  跳过应用目录拷贝"; return 0; }
    
    if [[ -d "$REPO_ROOT/applications" ]]; then
        copy "$REPO_ROOT/applications" "$APPS_ABS"
    fi
    
    local docs_root="$DOCS_DIR"
    local app_name="$(basename "$TARGET_DIR")"

    # 联邦模式：创建应用目录，并将原有 standalone 的 application/ 内容拷贝到 app-APPNAME/
    if [[ "$SDX_MODE" == "federation" ]]; then
        local app_dir="$APPS_ABS/app-$app_name"
        
        if [[ "$DRY_RUN" == "1" ]]; then
            dry_run "创建应用目录: app-$app_name"
        else
            ensure_dir "$APPS_ABS"
            if [[ ! -d "$app_dir" ]]; then
                ensure_dir "$app_dir"
                info "  创建应用目录: app-$app_name"
            fi
        fi

        local legacy_application_dir="$TARGET_DIR/$docs_root/application"
        if [[ -d "$legacy_application_dir" ]]; then
            info "  检测到原 application 目录，迁移到 app-$app_name"
            sync_dir_contents "$legacy_application_dir" "$app_dir"
            if [[ "$DRY_RUN" == "1" ]]; then
                dry_run "删除原 application 目录: $legacy_application_dir"
            else
                rm -rf "$legacy_application_dir"
                info "  已删除原 application 目录"
            fi
        fi
    else
        # 独立模式：若存在 app-APPNAME/（联邦模式遗留），拷贝其内容到 application/
        local legacy_app_dir="$TARGET_DIR/$docs_root/applications/app-$app_name"
        if [[ -d "$legacy_app_dir" ]]; then
            info "  检测到原 app-$app_name 目录，迁移到 application"
            sync_dir_contents "$legacy_app_dir" "$APPS_ABS"
            local legacy_applications_root="$TARGET_DIR/$docs_root/applications"
            if [[ "$DRY_RUN" == "1" ]]; then
                dry_run "删除原 applications 目录: $legacy_applications_root"
            else
                rm -rf "$legacy_applications_root"
                info "  已删除原 applications 目录"
            fi
        fi
    fi
}

handle_git() {
    local docs_root="$DOCS_DIR"
    if [[ -z "$docs_root" || "$docs_root" == "." ]]; then
        return 0
    fi
    
    if [[ "$SDX_MODE" == "federation" ]]; then
        setup_federation_git "$docs_root"
    else
        cleanup_standalone_git "$docs_root"
    fi
}

setup_federation_git() {
    local docs_root="$1"
    local gitignore="$TARGET_DIR/.gitignore"
    local -a patterns=("docs")
    local docs_abs="$TARGET_DIR/$docs_root"
    
    # 更新 .gitignore
    if [[ "$DRY_RUN" == "1" ]]; then
        if [[ -f "$gitignore" ]]; then
            dry_run "更新 .gitignore：确保包含忽略规则 -> ${patterns[*]}"
        else
            dry_run "创建 .gitignore：写入忽略规则 -> ${patterns[*]}"
        fi
    else
        local p
        if [[ -f "$gitignore" ]]; then
            local added=0
            for p in "${patterns[@]}"; do
                grep -q "^${p}\$" "$gitignore" || { 
                    [[ $added -eq 0 ]] && printf '\n# sdx-init 联邦模式：忽略文档根目录\n' >> "$gitignore"
                    printf '%s\n' "$p" >> "$gitignore"
                    added=1
                }
            done
            [[ $added -eq 1 ]] && info "  更新 .gitignore"
        else
            {
                echo "# sdx-init 联邦模式：忽略文档根目录"
                for p in "${patterns[@]}"; do
                    echo "$p"
                done
            } > "$gitignore"
            info "  创建 .gitignore"
        fi
    fi
    
    # 拷贝 .git
    if [[ -d "$REPO_ROOT/.git" ]]; then
        if [[ "$DRY_RUN" == "1" ]]; then
            dry_run "拷贝 .git: $REPO_ROOT/.git -> $docs_abs/.git（会覆盖目标 .git）"
            dry_run "设置文档 Git worktree: $docs_abs"
        else
            ensure_dir "$docs_abs"
            rm -rf "$docs_abs/.git"
            copy "$REPO_ROOT/.git" "$docs_abs/.git"
            (cd "$docs_abs" && git config core.worktree "$docs_abs") &>/dev/null || true
            info "  设置文档 Git 仓库"
        fi
    fi
}

cleanup_standalone_git() {
    local docs_root="$1"
    local docs_abs="$TARGET_DIR/$docs_root"
    local gitignore="$TARGET_DIR/.gitignore"
    local -a patterns=("docs")
    local removed=0
    
    # 清理 .git
    if [[ "$DRY_RUN" == "1" ]]; then
        if [[ -d "$docs_abs/.git" ]]; then
            dry_run "删除文档 .git: $docs_abs/.git"
        fi
    elif [[ -d "$docs_abs/.git" ]]; then
        rm -rf "$docs_abs/.git"
        info "  清理文档 .git"
    fi
    
    # 清理 .gitignore
    if [[ "$DRY_RUN" == "1" ]]; then
        local p
        for p in "${patterns[@]}"; do
            if [[ -f "$gitignore" ]] && grep -q "^${p}\$" "$gitignore"; then
                dry_run "清理 .gitignore：移除忽略规则 -> $p"
            fi
        done
    else
        local p
        if [[ -f "$gitignore" ]]; then
            for p in "${patterns[@]}"; do
                if grep -q "^${p}\$" "$gitignore"; then
                    removed=1
                fi
            done
        fi
    fi

    if [[ "$DRY_RUN" == "0" && "$removed" -eq 1 ]]; then
        local tmp="${gitignore}.tmp"
        # grep 在“全部被过滤掉”时会返回 1；这里仍应写回空文件
        {
            grep -v "^# sdx-init 联邦模式：忽略文档根目录$" "$gitignore" | \
            grep -v -e "^docs\$" > "$tmp"
        } || true
        mv "$tmp" "$gitignore"
        info "  清理 .gitignore"
    fi
}

copy_ai() {
    info ">>> 拷贝 AI 配置..."
    
    should_skip "$AI_ABS" && { info "  跳过 AI 配置拷贝"; return 0; }
    
    if [[ "$DRY_RUN" == "1" ]]; then
        dry_run "拷贝 .ai 配置（排除 skills）"
        if [[ "$AI_RULES_SCOPE" == "no-solution-analysis" ]]; then
            dry_run "排除 solution/analysis 规则"
        fi
        return 0
    fi
    
    # 拷贝 .ai（排除 skills）
    local -a ai_items=()
    local item
    mapfile -d '' -t ai_items < <(find "$REPO_ROOT/.ai" -mindepth 1 -maxdepth 1 ! -name 'skills' -print0)
    for item in "${ai_items[@]}"; do
        copy "$item" "$AI_ABS/$(basename "$item")"
    done
    
    # 处理规则范围
    if [[ "$AI_RULES_SCOPE" == "no-solution-analysis" ]]; then
        rm -rf "$AI_ABS/rules/solution" "$AI_ABS/rules/analysis"
        info "  排除 solution/analysis 规则"
    fi
    
    info "  AI 配置拷贝完成"
}

install_agents() {
    info ">>> 安装 Agent 和技能..."
    
    for agent in "${enabled_agents[@]}"; do
        case "$agent" in
            cursor) install_cursor ;;
            trea)   install_trea ;;
            *)      install_generic "$agent" ;;
        esac
    done
    
    info "  Agent 安装完成"
}

install_cursor() {
    should_skip "$CURSOR_ABS" && { info "  跳过 Cursor"; return 0; }
    
    if [[ "$DRY_RUN" == "1" ]]; then
        dry_run "安装 Cursor 技能和配置"
        return 0
    fi
    
    ensure_dir "$CURSOR_ABS/skills"
    
    # 安装技能
    for skill in "${install_skills[@]}"; do
        local src="$REPO_ROOT/.ai/skills/$skill"
        if [[ -d "$src" ]]; then
            copy "$src" "$CURSOR_ABS/skills/$skill"
        fi
    done
    
    # 生成 README
    generate_cursor_readme
    info "  安装 Cursor 完成"
}

generate_cursor_readme() {
    local readme="$CURSOR_ABS/README.md"
    
    {
        echo "# Cursor 项目配置"
        echo ""
        echo "## Slash 命令（Skills）"
        echo ""
        echo "| 命令 | 说明 |"
        echo "|------|------|"
        
        for skill in "${install_skills[@]}"; do
            local skill_file="$CURSOR_ABS/skills/$skill/SKILL.md"
            if [[ -f "$skill_file" ]]; then
                local desc
                desc=$(awk '/^description:/{getline; gsub(/^[ \t]+|[ \t]+$/,""); print; exit}' "$skill_file" 2>/dev/null)
                if [[ -z "$desc" ]]; then
                    desc="见 .cursor/skills/$skill/SKILL.md"
                fi
                echo "| \`/$skill\` | $desc |"
            fi
        done
        
        echo ""
        echo "在 Chat 中输入 \`/\` 后选择对应命令即可调用。"
    } > "$readme"
}

install_trea() {
    should_skip "$TREA_ABS" && { info "  跳过 Trea"; return 0; }
    
    if [[ ! -d "$REPO_ROOT/.trea" ]]; then
        info "  无 Trea 配置"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "1" ]]; then
        dry_run "安装 Trea 配置和技能"
        return 0
    fi
    
    copy "$REPO_ROOT/.trea" "$TREA_ABS"
    
    ensure_dir "$TREA_ABS/skills"
    for skill in "${install_skills[@]}"; do
        local src="$REPO_ROOT/.ai/skills/$skill"
        if [[ -d "$src" ]]; then
            copy "$src" "$TREA_ABS/skills/$skill"
        fi
    done
    
    info "  安装 Trea 完成"
}

install_generic() {
    local agent="$1"
    local dst="$TARGET_DIR/.$agent"
    
    should_skip "$dst" && { info "  跳过 $agent"; return 0; }
    
    local src="$REPO_ROOT/.$agent"
    if [[ ! -d "$src" ]]; then
        info "  无 $agent 配置"
        return 0
    fi
    
    copy "$src" "$dst"
    info "  安装 $agent 完成"
}

# ============================================================================
# 主程序
# ============================================================================

show_config() {
    info "配置信息:"
    info "  模式: $SDX_MODE"
    info "  仓库: $REPO_ROOT"
    info "  目标: $TARGET_DIR"
    info "  文档: $DOCS_DIR/system -> $SYSTEM_DOCS_ABS (范围: $DOCS_SCOPE)"
    info "  应用: $APPS_ABS"
    info "  AI: $AI_DIR -> $AI_ABS (规则: $AI_RULES_SCOPE)"
    info "  Agents: ${enabled_agents[*]}"
    info "  Skills: ${install_skills[*]}"
    if [[ "$DRY_RUN" == "1" ]]; then
        info "  [预览模式]"
    fi
    echo
}

show_summary() {
    echo
    info "初始化完成！"
    info "  文档系统: $SYSTEM_DOCS_ABS"
    info "  应用目录: $APPS_ABS"
    info "  AI 配置: $AI_ABS"
    info "  Agents: ${enabled_agents[*]}"
}

main() {
    parse_args "$@"
    init_repo
    validate_inputs
    init_paths
    discover_skills
    parse_agents
    parse_skills
    check_overwrites
    
    show_config
    
    copy_docs
    copy_ai
    install_agents
    
    show_summary
}

# 执行主程序
main "$@"