#!/usr/bin/env bash
#
# docs-config.sh — SDX 知识库初始化配置模块
#
# 目的:
#   提供知识库初始化脚本的共享常量、默认值与校验函数。
#   作为配置层，集中管理所有可配置参数及其合法取值。
#
# 意图:
#   - 单一事实源：所有默认值、支持的模式、校验逻辑集中在此
#   - 可扩展：新增配置只需修改此处，无需改动业务脚本
#   - 可验证：提供校验函数确保外部输入合法
#
# 依赖:
#   - Bash 5+ (使用关联数组)
#
# Usage (被 source，不直接执行):
#   source "$(dirname "$0")/docs-config.sh"
#

# -----------------------------------------------------------------------------
# 环境检查
# -----------------------------------------------------------------------------

# 要求 Bash 5+，用于关联数组、nameref 等特性
sdx_require_bash5() {
    if (( BASH_VERSINFO[0] < 5 )); then
        printf '[FATAL] 需要 Bash 5+，当前版本: %s\n' "$BASH_VERSION" >&2
        exit 1
    fi
}

# 确保已满足环境要求
sdx_require_bash5

# -----------------------------------------------------------------------------
# 常量定义
# -----------------------------------------------------------------------------

# 版本信息
readonly SDX_VERSION='2.1.1'
readonly SDX_MIN_BASH_VERSION=5

# Git 仓库地址（供 bootstrap 引用）
readonly SDX_GIT_REPO_URL='https://github.com/oleewen/ai-knowledge.git'

# 支持的模式
readonly -a SDX_SUPPORTED_MODES=(standalone central)

# 支持的 Agent 类型
readonly -a SDX_SUPPORTED_AGENTS=(cursor trea claude)

# Agent 到目录名的映射（使用命名数组）
declare -A SDX_AGENT_DIR_MAP=(
    [cursor]='.cursor'
    [trea]='.trea'
    [claude]='.claude'
)

# 源模板路径（相对于 REPO_ROOT）
# 现在使用 system/ 作为模板源（取代了原来的 applications/app-APPNAME）
readonly SDX_SYSTEM_TEMPLATE_PATH='system'

# 应用模板注册路径（central 模式下使用）
readonly SDX_APP_TEMPLATE_PATH='applications/app-APPNAME'

# standalone 模式下需要从 system/ 模板中排除的文件
readonly -a SDX_STANDALONE_EXCLUDE_FILES=(
    'DESIGN.md'
    'CONTRIBUTING.md'
)

# standalone 模式下需要排除的目录
readonly -a SDX_STANDALONE_EXCLUDE_DIRS=(
    'specs'
)

# 文本替换规则：应用模板时内容替换的映射
# 格式: '原文本|替换文本'
# 注：system/ → 实际文档目录（如system/）的替换在脚本运行时动态添加
readonly -a SDX_TEXT_REPLACEMENTS=(
    'system_|application_'
    '系统知识库|应用知识库'
    '系统|应用'
)

# 文件名替换规则：用于目录和文件名替换
declare -A SDX_FILENAME_REPLACEMENTS=(
    ['system']='application'
    ['system_meta']='application_meta'
    ['SYSTEM']='APPLICATION'
)

# 默认安装的技能前缀（用于 skills 目录筛选）
readonly -a SDX_DEFAULT_SKILL_PREFIXES=(
    'agent-'
    'document-'
    'knowledge-'
    'sdx-'
)

# 默认安装的技能列表
readonly -a SDX_DEFAULT_SKILLS=(
    'agent-guide'
    'docs-indexing'
    'docs-change'
    'sdx-solution'
    'sdx-analysis'
    'sdx-prd'
    'sdx-design'
    'sdx-test'
)

# -----------------------------------------------------------------------------
# 默认配置关联数组
# -----------------------------------------------------------------------------
#
# 说明:
#   这些默认值可被环境变量或命令行参数覆盖。
#   键名即为对应的环境变量名（小写）。
#

declare -A SDX_DEFAULTS=(
    [docs_dir]='docs'                       # 目标文档目录名
    [mode]='standalone'                     # 运行模式: standalone | s | central | c
    [agents]='cursor'                       # Agent 类型: cursor | trea | claude | all
)

# -----------------------------------------------------------------------------
# 验证函数（返回 0 表示合法，1 表示非法）
# -----------------------------------------------------------------------------

# 验证运行模式是否合法
# Usage: sdx_validate_mode <mode>
# Returns: 0=合法, 1=非法
sdx_validate_mode() {
    local mode="${1:-}"
    [[ "$mode" =~ ^(standalone|central|s|c)$ ]] && return 0
    return 1
}

# 规范化运行模式（统一为完整名称）
# Usage: sdx_normalize_mode <mode>
# stdout: standalone | central
sdx_normalize_mode() {
    local mode="${1:-}"
    case "$mode" in
        s|standalone) echo 'standalone' ;;
        c|central)    echo 'central' ;;
        *)            echo 'standalone' ;;  # 默认回退
    esac
}

# 验证 Agent 列表是否合法
# Usage: sdx_validate_agents <agents>
# <agents>: 逗号分隔或空格分隔的列表，如 "cursor,trea" 或 "cursor trea"
# Returns: 0=全部合法, 1=存在非法
sdx_validate_agents() {
    local agents_str="${1:-}"
    local -a agents

    # 支持逗号或空格分隔
    IFS=', ' read -ra agents <<< "$agents_str"

    for agent in "${agents[@]}"; do
        [[ -z "$agent" ]] && continue  # 跳过空值
        [[ "$agent" == 'all' ]] && return 0  # all 表示全部合法

        local valid=0
        for supported in "${SDX_SUPPORTED_AGENTS[@]}"; do
            [[ "$agent" == "$supported" ]] && { valid=1; break; }
        done
        (( valid == 0 )) && return 1
    done
    return 0
}

# 规范化 Agent 列表（展开 all，去重）
# Usage: sdx_normalize_agents <agents>
# stdout: 空格分隔的 Agent 列表
sdx_normalize_agents() {
    local agents_str="${1:-}"

    if [[ "$agents_str" == 'all' ]]; then
        echo "${SDX_SUPPORTED_AGENTS[*]}"
        return 0
    fi

    local -a agents normalized
    local -A seen

    IFS=', ' read -ra agents <<< "$agents_str"

    for agent in "${agents[@]}"; do
        [[ -z "$agent" ]] && continue
        [[ -v seen["$agent"] ]] && continue  # 去重
        seen["$agent"]=1
        normalized+=("$agent")
    done

    echo "${normalized[*]}"
}

# 获取 Agent 对应的目录名
# Usage: sdx_get_agent_dir <agent>
# stdout: Agent 目录名（如 .cursor）
sdx_get_agent_dir() {
    local agent="${1:-}"
    echo "${SDX_AGENT_DIR_MAP[$agent]:-.agent}"
}

# -----------------------------------------------------------------------------
# 默认值获取函数
# -----------------------------------------------------------------------------

# 获取配置项的默认值
# Usage: sdx_default <key>
# stdout: 默认值
sdx_default() {
    local key="${1:-}"
    printf '%s' "${SDX_DEFAULTS[$key]:-}"
}

# -----------------------------------------------------------------------------
# 路径处理函数（纯函数，无副作用）
# -----------------------------------------------------------------------------

# 展开路径中的 ~ 为用户主目录
# Usage: sdx_expand_tilde <path>
# stdout: 展开后的路径
sdx_expand_tilde() {
    local p="${1:-}"
    case "$p" in
        '~')           echo "$HOME" ;;
        '~/'*)         echo "$HOME/${p#~/}" ;;
        '~'/*)         echo "$HOME${p#~}" ;;
        '~'[a-zA-Z]*)  # 不支持其他用户的 ~username
            echo "$p" ;;  # 原样返回
        *)             echo "$p" ;;
    esac
}

# 获取绝对路径（不检查存在性）
# Usage: sdx_abs_path <path>
# stdout: 绝对路径
sdx_abs_path() {
    local p
    p="$(sdx_expand_tilde "${1:-}")"

    if [[ "$p" != /* ]]; then
        p="$PWD/$p"
    fi

    # 清理路径中的 .. 和 .
    # 使用 cd -P 获取物理路径（解析符号链接）
    if [[ -d "$p" ]]; then
        (cd -P "$p" 2>/dev/null && pwd)
    else
        # 对于文件，获取其所在目录的绝对路径，再拼接文件名
        local dir base orig_dir
        dir="$(dirname "$p")"
        orig_dir="$dir"
        base="$(basename "$p")"
        if dir="$(cd -P "$dir" 2>/dev/null && pwd)"; then
            :
        else
            dir="$orig_dir"
        fi
        echo "$dir/$base"
    fi
}

# 去除路径末尾的斜杠（保留根目录 /）
# Usage: sdx_strip_trailing_slash <path>
# stdout: 处理后的路径
sdx_strip_trailing_slash() {
    local p="${1:-}"
    while [[ "$p" != '/' && "$p" == */ ]]; do
        p="${p%/}"
    done
    echo "$p"
}

# 计算相对路径（从 base 到 target）
# Usage: sdx_rel_path <base> <target>
# stdout: target 相对于 base 的路径
sdx_rel_path() {
    local base="${1:-}"
    local target="${2:-}"

    base="$(sdx_strip_trailing_slash "$base")"
    target="$(sdx_strip_trailing_slash "$target")"

    case "$target" in
        "$base")     echo '.' ;;
        "$base"/*)   echo "${target#$base/}" ;;
        *)           echo "$target" ;;
    esac
}

# -----------------------------------------------------------------------------
# 应用 ID 处理函数
# -----------------------------------------------------------------------------

# 从目录名生成合法的应用 ID
# 规则: 大写，非字母数字转 -，去重连续 -， trim 首尾 -
# Usage: sdx_sanitize_app_id <raw_name>
# stdout: APP-XXXX 格式 ID
sdx_sanitize_app_id() {
    local raw="${1:-}"

    # 提取目录名（去除路径）
    raw="${raw##*/}"

    # 转为大写，非字母数字替换为 -
    raw="$(printf '%s' "$raw" | tr '[:lower:]' '[:upper:]' | tr -c '[:alnum:]' '-')"

    # 去重连续 -，trim 首尾 -
    while [[ "$raw" == --* ]]; do raw="${raw#-}"; done
    while [[ "$raw" == *-- ]]; do raw="${raw%-}"; done
    raw="$(printf '%s' "$raw" | tr -s '-')"

    # 确保非空
    if [[ -z "$raw" ]]; then
        raw='APPNAME'
    fi

    echo "APP-${raw}"
}

# 替换文件名中的 system 为 application
# Usage: sdx_replace_filename <filename>
# stdout: 替换后的文件名
sdx_replace_filename() {
    local filename="${1:-}"

    for key in "${!SDX_FILENAME_REPLACEMENTS[@]}"; do
        local value="${SDX_FILENAME_REPLACEMENTS[$key]}"
        filename="${filename//$key/$value}"
    done

    echo "$filename"
}

# -----------------------------------------------------------------------------
# 检查清单文本（纯数据）
# -----------------------------------------------------------------------------

# 输出初始化后的建议核对项
# Usage: sdx_post_init_checklist [target_docs_dir]
sdx_post_init_checklist() {
    local target_docs="${1:-<目标文档目录>}"

    cat <<CHECKLIST

================================================================================
初始化完成！建议核对清单
================================================================================

[ ] application_meta.yaml 已随模板落地；若目录名不再是 app-APPNAME，
    可酌情更新其中 template_directory 或描述，避免误导 Agent

[ ] INDEX_GUIDE.md 内相对链接在目标工程中可访问

[ ] knowledge/knowledge_meta.yaml、requirements/requirements_meta.yaml、
    changelogs/changelogs_meta.yaml 与各目录 README 首段「元数据」链一致

[ ] knowledge/constitution/：principles_meta.yaml、standards_meta.yaml、
    adr/adr_meta.yaml（若存在）与 constitution/README.md 组件表互链

[ ] 正式需求包：自 REQUIREMENT-EXAMPLE 复制为 REQUIREMENT-{ID}/；
    REQUIREMENT-EXAMPLE 为结构示例，不单建 *_meta.yaml（见 requirements/README.md）

[ ] central 模式：核对本仓库 system/SYSTEM_INDEX.md「五、中央知识库接入工程」登记行与
    applications/app-<后缀>/APPNAME_manifest.yaml 是否反映当前工程与文档路径

[ ] Agent 配置：检查用户主目录下 ~/.cursor/ 或 ~/.trea/ 等目录中 skills 和 rules 是否正确安装（非工程目录）

================================================================================
CHECKLIST
}
