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
require_bash5() {
    if (( BASH_VERSINFO[0] < 5 )); then
        printf '[FATAL] 需要 Bash 5+，当前版本: %s\n' "$BASH_VERSION" >&2
        exit 1
    fi
}

# 确保已满足环境要求
require_bash5

# -----------------------------------------------------------------------------
# 常量定义
# -----------------------------------------------------------------------------

# 版本信息
readonly SDX_VERSION='2.3.0'
readonly SDX_MIN_BASH_VERSION=5

# Git 仓库地址（供 bootstrap 引用）
readonly SDX_GIT_REPO_URL='https://github.com/oleewen/ai-knowledge.git'

# 支持的模式
readonly -a SDX_SUPPORTED_MODES=(standalone central)

# 支持的 docs-init --type（知识库 v2，见 docs/superpowers/specs/2026-04-07-knowledge-layout-v2-design.md §6）
readonly -a SDX_SUPPORTED_TYPES=(application system company)

# 支持的 Agent 类型
readonly -a SDX_SUPPORTED_AGENTS=(cursor trea claude)

# Agent 到目录名的映射（使用命名数组）
declare -A SDX_AGENT_DIR_MAP=(
    [cursor]='.cursor'
    [trea]='.trea'
    [claude]='.claude'
)

# 源模板路径（相对于 REPO_ROOT）
# 现在使用 application/ 作为应用知识库模板源（取代了原来的 applications/app-APPNAME）
readonly SDX_SYSTEM_TEMPLATE_PATH='application'

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
    ['system_meta']='docs_meta'
    ['application_meta']='docs_meta'
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
# Usage: validate_mode <mode>
# Returns: 0=合法, 1=非法
validate_mode() {
    local mode="${1:-}"
    [[ "$mode" =~ ^(standalone|central|s|c)$ ]] && return 0
    return 1
}

# 规范化运行模式（统一为完整名称）
# Usage: normalize_mode <mode>
# stdout: standalone | central
normalize_mode() {
    local mode="${1:-}"
    case "$mode" in
        s|standalone) echo 'standalone' ;;
        c|central)    echo 'central' ;;
        *)            echo 'standalone' ;;  # 默认回退
    esac
}

# 验证 --type 是否合法
# Usage: validate_type <type>
validate_type() {
    local t="${1:-}"
    [[ "$t" =~ ^(application|system|company)$ ]] && return 0
    return 1
}

# 规范化 --type（别名 → 标准值）
# Usage: normalize_type <type>
# stdout: application | system | company
normalize_type() {
    local raw="${1:-}"
    case "${raw,,}" in
        application|a) echo 'application' ;;
        system|s)      echo 'system' ;;
        company|c)    echo 'company' ;;
        *)                 printf '%s' "$raw" ;;
    esac
}

# 验证 Agent 列表是否合法
# Usage: validate_agents <agents>
# <agents>: 逗号分隔或空格分隔的列表，如 "cursor,trea" 或 "cursor trea"
# Returns: 0=全部合法, 1=存在非法
validate_agents() {
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
# Usage: normalize_agents <agents>
# stdout: 空格分隔的 Agent 列表
normalize_agents() {
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
# Usage: get_agent_dir <agent>
# stdout: Agent 目录名（如 .cursor）
get_agent_dir() {
    local agent="${1:-}"
    echo "${SDX_AGENT_DIR_MAP[$agent]:-.agent}"
}

# -----------------------------------------------------------------------------
# 默认值获取函数
# -----------------------------------------------------------------------------

# 获取配置项的默认值
# Usage: cfg_default <key>
# stdout: 默认值
cfg_default() {
    local key="${1:-}"
    printf '%s' "${SDX_DEFAULTS[$key]:-}"
}

# -----------------------------------------------------------------------------
# 路径处理函数（纯函数，无副作用）
# -----------------------------------------------------------------------------

# 展开路径中的 ~ 为用户主目录
# Usage: expand_tilde <path>
# stdout: 展开后的路径
expand_tilde() {
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
# Usage: abs_path <path>
# stdout: 绝对路径
abs_path() {
    local p
    p="$(expand_tilde "${1:-}")"

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
# Usage: strip_trailing_slash <path>
# stdout: 处理后的路径
strip_trailing_slash() {
    local p="${1:-}"
    while [[ "$p" != '/' && "$p" == */ ]]; do
        p="${p%/}"
    done
    echo "$p"
}

# 计算相对路径（从 base 到 target）
# Usage: rel_path <base> <target>
# stdout: target 相对于 base 的路径
rel_path() {
    local base="${1:-}"
    local target="${2:-}"

    base="$(strip_trailing_slash "$base")"
    target="$(strip_trailing_slash "$target")"

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
# Usage: sanitize_app_id <raw_name>
# stdout: APP-XXXX 格式 ID
sanitize_app_id() {
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
# Usage: replace_filename <filename>
# stdout: 替换后的文件名
replace_filename() {
    local filename="${1:-}"

    for key in "${!SDX_FILENAME_REPLACEMENTS[@]}"; do
        local value="${SDX_FILENAME_REPLACEMENTS[$key]}"
        filename="${filename//$key/$value}"
    done

    echo "$filename"
}

# -----------------------------------------------------------------------------
# `.docsconfig`（目标工程仓库根，见 docs/superpowers/specs/2026-04-08-docsconfig-docs-init-design.md）
# -----------------------------------------------------------------------------

# 由 DOC_ROOT 解析 Git 仓库根（§3.3 推荐失败则返回空）
# Usage: docsconfig_repo_root_from_doc_root <doc_root_abs>
# stdout: REPO_ROOT 绝对路径
docsconfig_repo_root_from_doc_root() {
    local doc_root="${1:?doc_root}"
    git -C "$doc_root" rev-parse --show-toplevel 2>/dev/null || true
}

# 由 REPO_ROOT + DOC_ROOT 推算 DOC_DIR（相对段；重合时为 "."）
# Usage: docsconfig_doc_dir_from_roots <repo_root_abs> <doc_root_abs>
# stdout: DOC_DIR（无前导 /）
# 失败：stderr 说明并返回 1
docsconfig_doc_dir_from_roots() {
    local repo_root="${1:?repo_root}"
    local doc_root="${2:?doc_root}"
    local rr dr
    rr="$(cd -P "$repo_root" 2>/dev/null && pwd)" || {
        printf '%s\n' "[docsconfig] 无法解析 REPO_ROOT: $repo_root" >&2
        return 1
    }
    dr="$(cd -P "$doc_root" 2>/dev/null && pwd)" || {
        printf '%s\n' "[docsconfig] 无法解析 DOC_ROOT: $doc_root" >&2
        return 1
    }
    case "$dr" in
        "$rr") printf '%s\n' '.' ;;
        "$rr"/*) printf '%s\n' "${dr#"$rr"/}" ;;
        *)
            printf '%s\n' "[docsconfig] DOC_ROOT 不在 REPO_ROOT 下: $dr vs $rr" >&2
            return 1
            ;;
    esac
}

# 写入 $REPO_ROOT/.docsconfig（三键，UTF-8）
# Usage: docsconfig_write <repo_root> <doc_root> <doc_dir> [dry_run:0|1]
docsconfig_write() {
    local repo_root="${1:?repo_root}"
    local doc_root="${2:?doc_root}"
    local doc_dir="${3:?doc_dir}"
    local dry="${4:-0}"
    local out="$repo_root/.docsconfig"
    if [[ "$dry" == "1" ]]; then
        printf 'Would write %s:\nDOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' \
            "$out" "$doc_root" "$repo_root" "$doc_dir"
        return 0
    fi
    umask 022
    printf 'DOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' \
        "$doc_root" "$repo_root" "$doc_dir" >"$out"
}

# 自文件解析 DOC_ROOT / REPO_ROOT / DOC_DIR（nameref 输出，Bash 5+）
# 某键缺失则对应变量为空（用于缺 DOC_DIR 等迁移场景）。
# Usage: docsconfig_read_into <path> <nameref_doc_root> <nameref_repo_root> <nameref_doc_dir>
# Returns: 0 文件存在且已解析；1 文件不存在或不可读
docsconfig_read_into() {
    local path="${1:?path}"
    local -n _doc="${2:?}"
    local -n _repo="${3:?}"
    local -n _ddir="${4:?}"
    _doc=""
    _repo=""
    _ddir=""
    [[ -f "$path" ]] || return 1
    local line k v
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        case "$line" in
            DOC_ROOT=* | REPO_ROOT=* | DOC_DIR=*)
                k="${line%%=*}"
                v="${line#*=}"
                v="${v%$'\r'}"
                case "$k" in
                    DOC_ROOT) _doc="$v" ;;
                    REPO_ROOT) _repo="$v" ;;
                    DOC_DIR) _ddir="$v" ;;
                esac
                ;;
        esac
    done <"$path"
    return 0
}

# 输出文件中匹配 KEY= 的行（调试用或简单管道）
# Usage: docsconfig_grep_keys <path>
docsconfig_grep_keys() {
    local path="${1:?path}"
    [[ -f "$path" ]] || return 1
    grep -E '^(DOC_ROOT|REPO_ROOT|DOC_DIR)=' "$path" 2>/dev/null
}

# -----------------------------------------------------------------------------
# 检查清单文本（纯数据）
# -----------------------------------------------------------------------------

# 输出初始化后的建议核对项
# Usage: post_init_checklist [target_docs_dir]
post_init_checklist() {
    local target_docs="${1:-<目标文档目录>}"

    cat <<CHECKLIST

================================================================================
初始化完成！建议核对清单
================================================================================

[ ] docs_meta.yaml 已随模板落地；若目录名不再是 app-APPNAME，
    可酌情更新其中 template_directory 或描述，避免误导 Agent

[ ] INDEX_GUIDE.md 内相对链接在目标工程中可访问

[ ] knowledge/knowledge_meta.yaml、requirements/requirements_meta.yaml、
    changelogs/changelogs_meta.yaml 与各目录 README 首段「元数据」链一致

[ ] constitution/：principles_meta.yaml、standards_meta.yaml、
    adr/adr_meta.yaml（若存在）与 constitution/README.md 组件表互链

[ ] 正式需求包：自 REQUIREMENT-EXAMPLE 复制为 REQUIREMENT-{ID}/；
    REQUIREMENT-EXAMPLE 为结构示例，不单建 *_meta.yaml（见 requirements/README.md）

[ ] central + type=application：核对本仓库 application/INDEX_GUIDE.md「十、中央知识库接入工程」登记行与
    system/application-<后缀>/ 槽位是否与目标工程一致（v2.3 起联邦槽位在 system/ 下）

[ ] Agent 配置：检查用户主目录下 ~/.cursor/ 或 ~/.trea/ 等目录中 skills 和 rules 是否正确安装（非工程目录）

================================================================================
CHECKLIST
}
