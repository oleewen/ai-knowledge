#!/usr/bin/env bash
# agent-init.sh — 仅安装 Agent（scripts / rules / skills）与 .docsconfig
#
# 本文件自包含：不 source scripts/lib/*.sh 或 docs-config.sh；与 knowledge-init 并行维护。
# 与 docs-config / docs-init-core 同步：bash scripts/maintain-agent-init.sh
#
# --- 复用策略（已选 A） ---
# A) 多份实现：agent-init、knowledge-init 均自包含；docs-config.sh + lib/docs-init-core.sh 为对照 SSOT；
#    maintain-agent-init.sh 仅从 SSOT 生成 agent-init。变更时须同步：SSOT、knowledge-init 内联段、再跑 maintain。
#    （未选 B：公共 source 库；未选 C：正式生成管线。）
#
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# ========== docs-config.sh（内联）==========
# 要求 Bash 5+，用于关联数组、nameref 等特性
require_bash5() {
  if (( BASH_VERSINFO[0] < 5 )); then
    printf '[FATAL] 需要 Bash 5+，当前版本: %s\n' "$BASH_VERSION" >&2
    exit 1
  fi
}
require_bash5

# =============================================================================
# § 1  版本与仓库常量
# =============================================================================

readonly SDX_VERSION='2.9.0'
readonly SDX_MIN_BASH_VERSION=5

# Git 仓库地址（供 bootstrap 引用）
# 注意：`docs-bootstrap.sh` 在首次 clone 前无法 source 本文件；若使用预克隆后备 URL（`SDX_BS_FALLBACK_REPO`），
# 其字符串必须与下列赋值完全一致（集成测试 `test_BS_URL_SYNC` 会校验）。
readonly SDX_GIT_REPO_URL='https://github.com/oleewen/ai-knowledge.git'

# =============================================================================
# § 2  支持的枚举值
# =============================================================================

# 支持的运行模式
readonly -a SDX_SUPPORTED_MODES=(standalone central)

# 支持的知识库类型（--type，知识库 v2）
readonly -a SDX_SUPPORTED_TYPES=(application system company)

# .docsconfig 中 KNOWLEDGE_TYPE 取值（与 SDX_SUPPORTED_TYPES 一致）
readonly -a SDX_SUPPORTED_KNOWLEDGE_TYPES=(application system company)

# 支持的 Agent 类型
readonly -a SDX_SUPPORTED_AGENTS=(cursor trea claude)

# Agent 名称 → 目录名映射
declare -A SDX_AGENT_DIR_MAP=(
  [cursor]='.cursor'
  [trea]='.trea'
  [claude]='.claude'
)

# =============================================================================
# § 3  模板路径与排除规则
# =============================================================================

# 应用知识库模板源（相对于 REPO_ROOT）
readonly SDX_SYSTEM_TEMPLATE_PATH='application'

# standalone 模式下从 application/ 模板中排除的顶层文件
readonly -a SDX_STANDALONE_EXCLUDE_FILES=(
  'DESIGN.md'
  'CONTRIBUTING.md'
)

# standalone 模式下排除的顶层目录
readonly -a SDX_STANDALONE_EXCLUDE_DIRS=(
  'specs'
)

# =============================================================================
# § 4  替换规则（文本 / 文件名）
# =============================================================================

# 文本替换规则，格式：'原文本|替换文本'
# 注：system/ → 实际文档目录的替换在运行时动态添加
readonly -a SDX_TEXT_REPLACEMENTS=(
  'system_|application_'
  '系统知识库|应用知识库'
  '系统|应用'
)

# 文件名替换规则
declare -A SDX_FILENAME_REPLACEMENTS=(
  ['system']='application'
  ['system_meta']='docs_meta'
  ['application_meta']='docs_meta'
  ['SYSTEM']='APPLICATION'
)

# =============================================================================
# § 5  默认技能列表
# =============================================================================

# 默认安装的技能目录前缀（用于筛选）
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

# =============================================================================
# § 6  默认配置关联数组
# =============================================================================
#
# 这些默认值可被环境变量或命令行参数覆盖；键名即对应的环境变量名（小写）。
#
declare -A SDX_DEFAULTS=(
  [docs_dir]='docs'        # 目标文档目录名
  [mode]='standalone'      # 运行模式: standalone | central
  [agents]='cursor'        # Agent 类型: cursor | trea | claude | all
)

# =============================================================================
# § 7  枚举校验与规范化函数
# =============================================================================

# 校验运行模式是否合法
# 用法：validate_mode <mode>
# 返回：0=合法，1=非法
validate_mode() {
  [[ "${1:-}" =~ ^(standalone|central|s|c)$ ]]
}

# 规范化运行模式（别名 → 完整名称）
# 用法：normalize_mode <mode>
# 输出：standalone | central
normalize_mode() {
  case "${1:-}" in
    s|standalone) printf 'standalone' ;;
    c|central)    printf 'central'    ;;
    *)            printf 'standalone' ;;  # 默认回退
  esac
}

# 校验 --type 是否合法
# 用法：validate_type <type>
# 返回：0=合法，1=非法
validate_type() {
  [[ "${1:-}" =~ ^(application|system|company)$ ]]
}

# 规范化 --type（别名 → 标准值）
# 用法：normalize_type <type>
# 输出：application | system | company
normalize_type() {
  case "${1,,}" in
    application|a) printf 'application' ;;
    system|s)      printf 'system'      ;;
    company|c)     printf 'company'     ;;
    *)             printf '%s' "${1:-}" ;;
  esac
}

# 校验 Agent 列表是否合法（逗号或空格分隔）
# 用法：validate_agents <agents_str>
# 返回：0=全部合法，1=存在非法值
validate_agents() {
  local agents_str="${1:-}"
  local -a agents
  IFS=', ' read -ra agents <<< "$agents_str"

  local agent supported
  for agent in "${agents[@]}"; do
    [[ -z "$agent" ]] && continue
    [[ "$agent" == 'all' ]] && return 0

    local valid=0
    for supported in "${SDX_SUPPORTED_AGENTS[@]}"; do
      [[ "$agent" == "$supported" ]] && { valid=1; break; }
    done
    (( valid == 0 )) && return 1
  done
  return 0
}

# 规范化 Agent 列表（展开 all，去重）
# 用法：normalize_agents <agents_str>
# 输出：空格分隔的 Agent 列表
normalize_agents() {
  local agents_str="${1:-}"

  if [[ "$agents_str" == 'all' ]]; then
    printf '%s' "${SDX_SUPPORTED_AGENTS[*]}"
    return 0
  fi

  local -a agents normalized
  local -A seen
  IFS=', ' read -ra agents <<< "$agents_str"

  local agent
  for agent in "${agents[@]}"; do
    [[ -z "$agent" ]] && continue
    [[ -n "${seen[$agent]+x}" ]] && continue
    seen["$agent"]=1
    normalized+=("$agent")
  done

  printf '%s' "${normalized[*]}"
}

# 获取 Agent 对应的目录名
# 用法：get_agent_dir <agent>
# 输出：Agent 目录名（如 .cursor）；未知 agent 回退 agent
get_agent_dir() {
  printf '%s' "${SDX_AGENT_DIR_MAP[${1:-}]:-agent}"
}

# 获取配置项的默认值
# 用法：cfg_default <key>
cfg_default() {
  printf '%s' "${SDX_DEFAULTS[${1:-}]:-}"
}

# =============================================================================
# § 8  路径处理函数（纯函数，无副作用）
# =============================================================================

# 展开路径中的 ~ 为用户主目录
# 注意：不可用 case '~/'*) — bash 会对 case 模式做 tilde 展开，导致无法匹配字面 ~/
# 用法：expand_tilde <path>
expand_tilde() {
  local p="${1:-}"
  if [[ "$p" == '~' ]]; then
    printf '%s\n' "${HOME:-}"
  elif [[ "$p" =~ ^~/ ]]; then
    # 不可用 ${p#~/}：pattern 中 ~ 会经 tilde 展开，导致去前缀失败
    printf '%s\n' "${HOME:-}/${p:2}"
  else
    printf '%s\n' "$p"
  fi
}

# 获取绝对路径（不要求路径已存在；解析符号链接）
# 用法：abs_path <path>
abs_path() {
  local p
  p="$(expand_tilde "${1:-}")"
  [[ "$p" == /* ]] || p="$PWD/$p"

  if [[ -d "$p" ]]; then
    (cd -P "$p" 2>/dev/null && pwd)
  else
    local dir base
    dir="$(dirname "$p")"
    base="$(basename "$p")"
    dir="$(cd -P "$dir" 2>/dev/null && pwd || printf '%s' "$dir")"
    printf '%s/%s\n' "$dir" "$base"
  fi
}

# 去除路径末尾的斜杠（保留根目录 /）
# 用法：strip_trailing_slash <path>
strip_trailing_slash() {
  local p="${1:-}"
  while [[ "$p" != '/' && "$p" == */ ]]; do
    p="${p%/}"
  done
  printf '%s\n' "$p"
}

# 计算相对路径（从 base 到 target）
# 用法：rel_path <base> <target>
rel_path() {
  local base target
  base="$(strip_trailing_slash "${1:-}")"
  target="$(strip_trailing_slash "${2:-}")"
  case "$target" in
    "$base")   printf '.\n'                    ;;
    "$base"/*) printf '%s\n' "${target#"$base"/}" ;;
    *)         printf '%s\n' "$target"         ;;
  esac
}

# =============================================================================
# § 9  应用 ID 处理函数
# =============================================================================

# 从目录名生成合法的应用 ID
# 规则：大写，非字母数字转 -，合并连续 -，去除首尾 -
# 用法：sanitize_app_id <raw_name>
# 输出：APP-XXXX 格式 ID
sanitize_app_id() {
  local raw="${1##*/}"  # 去除路径前缀，只保留目录名

  # 转大写，非字母数字替换为 -
  raw="$(printf '%s' "$raw" | tr '[:lower:]' '[:upper:]' | tr -c '[:alnum:]' '-')"
  # 合并连续 -，去除首尾 -
  raw="$(printf '%s' "$raw" | tr -s '-' | sed 's/^-//;s/-$//')"

  printf 'APP-%s\n' "${raw:-APPNAME}"
}

# 替换文件名中的 system → application（按 SDX_FILENAME_REPLACEMENTS 映射）
# 用法：replace_filename <filename>
replace_filename() {
  local filename="${1:-}" key
  for key in "${!SDX_FILENAME_REPLACEMENTS[@]}"; do
    filename="${filename//$key/${SDX_FILENAME_REPLACEMENTS[$key]}}"
  done
  printf '%s\n' "$filename"
}

# =============================================================================
# § 10  .docsconfig 读写函数
#
# 规范见 docs/superpowers/specs/2026-04-08-docsconfig-docs-init-design.md
# =============================================================================

# 将绝对路径格式化为写入 .docsconfig 的值（位于 $HOME 下则输出 ~/...）
# 用法：docsconfig_format_root_for_write <abs_path>
docsconfig_format_root_for_write() {
  local p home
  p="$(strip_trailing_slash "$(abs_path "${1:?}")")"
  [[ -n "${HOME:-}" ]] || { printf '%s\n' "$p"; return 0; }
  home="$(strip_trailing_slash "$(abs_path "$HOME")")"
  [[ -n "$home" ]] || { printf '%s\n' "$p"; return 0; }

  if   [[ "$p" == "$home"   ]]; then printf '~\n'
  elif [[ "$p" == "$home"/* ]]; then printf '~/%s\n' "${p#"$home"/}"
  else                               printf '%s\n' "$p"
  fi
}

# 将 .docsconfig 中读入的 *_ROOT 原始值展开为绝对路径
# 用法：docsconfig_normalize_root_value <raw>
docsconfig_normalize_root_value() {
  local v="${1:-}"
  v="${v%$'\r'}"  # 去除 Windows 换行符
  printf '%s' "$(abs_path "$v")"
}

# 由 DOC_ROOT 解析所在 Git 仓库根（§3.3；仅当 DOC_ROOT 是仓库根的直接子目录时采用）
# 用法：docsconfig_repo_root_from_doc_root <doc_root_abs>
# 输出：REPO_ROOT 绝对路径；无法解析时输出空
docsconfig_repo_root_from_doc_root() {
  local doc_root="${1:?doc_root}"
  local dr gr
  dr="$(cd -P "$doc_root" 2>/dev/null && pwd)" || return 0
  gr="$(git -C "$dr" rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -n "$gr" ]] || return 0
  # 仅在 DOC_ROOT 是 Git 根的直接子目录时采用，避免被上层父仓库"吸走"
  if [[ "$(dirname "$dr")" == "$gr" ]]; then
    printf '%s\n' "$gr"
  fi
  return 0
}

# 由 DOC_ROOT 兜底推导 REPO_ROOT（取父目录）
# 用法：docsconfig_repo_root_fallback_from_doc_root <doc_root_abs>
# 输出：REPO_ROOT 绝对路径；失败返回空
docsconfig_repo_root_fallback_from_doc_root() {
  local doc_root="${1:?doc_root}"
  cd -P "$(dirname "$doc_root")" 2>/dev/null && pwd || true
}

# 由 REPO_ROOT + DOC_ROOT 推算 DOC_DIR（相对段；重合时为 "."）
# 用法：docsconfig_doc_dir_from_roots <repo_root_abs> <doc_root_abs>
# 输出：DOC_DIR（无前导 /）；失败时 stderr 说明并返回 1
docsconfig_doc_dir_from_roots() {
  local repo_root="${1:?repo_root}" doc_root="${2:?doc_root}"
  local rr dr
  rr="$(cd -P "$repo_root" 2>/dev/null && pwd)" \
    || { printf '[docsconfig] 无法解析 REPO_ROOT: %s\n' "$repo_root" >&2; return 1; }
  dr="$(cd -P "$doc_root"  2>/dev/null && pwd)" \
    || { printf '[docsconfig] 无法解析 DOC_ROOT: %s\n'  "$doc_root"  >&2; return 1; }

  case "$dr" in
    "$rr")   printf '.\n' ;;
    "$rr"/*) printf '%s\n' "${dr#"$rr"/}" ;;
    *)
      printf '[docsconfig] DOC_ROOT 不在 REPO_ROOT 下: %s vs %s\n' "$dr" "$rr" >&2
      return 1
      ;;
  esac
}

# 校验 KNOWLEDGE_TYPE 取值；合法返回 0，否则 stderr 并返回 1（空值视为非法，调用方勿传空）
docsconfig_validate_knowledge_type() {
  local v="${1:-}"
  local t
  for t in "${SDX_SUPPORTED_KNOWLEDGE_TYPES[@]}"; do
    [[ "$v" == "$t" ]] && return 0
  done
  printf '[docsconfig] 非法 KNOWLEDGE_TYPE: %s（允许: %s）\n' \
    "$v" "${SDX_SUPPORTED_KNOWLEDGE_TYPES[*]}" >&2
  return 1
}

# 写入 $REPO_ROOT/.docsconfig（至少三键；可选 KNOWLEDGE_TYPE；可选 AGENT_*）
# 用法：docsconfig_write <repo_root_abs> <doc_root_abs> <doc_dir> <dry_run:0|1> \
#                        [agent_root_abs] [agent_dirs_space_separated] [knowledge_type]
# 说明：knowledge_type 非空时须为 SDX_SUPPORTED_KNOWLEDGE_TYPES 之一；追加 KNOWLEDGE_TYPE=
#       agent_root_abs 非空时追加 AGENT_ROOT= 与 AGENT_DIRS="..."
docsconfig_write() {
  local repo_root="${1:?repo_root}"
  local doc_root="${2:?doc_root}"
  local doc_dir="${3:?doc_dir}"
  local dry="${4:-0}"
  local agent_root_in="${5:-}"
  local agent_dirs_in="${6:-}"
  local knowledge_type_in="${7:-}"

  local out rr dr ar
  out="$(strip_trailing_slash "$(abs_path "$repo_root")")/.docsconfig"
  rr="$(docsconfig_format_root_for_write "$repo_root")"
  dr="$(docsconfig_format_root_for_write "$doc_root")"

  if [[ -n "$knowledge_type_in" ]]; then
    docsconfig_validate_knowledge_type "$knowledge_type_in" || return 1
  fi

  # dry-run：仅预览，不写入
  if [[ "$dry" == '1' ]]; then
    printf 'Would write %s:\nDOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$out" "$dr" "$rr" "$doc_dir"
    if [[ -n "$knowledge_type_in" ]]; then
      printf 'KNOWLEDGE_TYPE=%s\n' "$knowledge_type_in"
    fi
    if [[ -n "$agent_root_in" ]]; then
      ar="$(docsconfig_format_root_for_write "$agent_root_in")"
      printf 'AGENT_ROOT=%s\nAGENT_DIRS="%s"\n' "$ar" "$agent_dirs_in"
    fi
    return 0
  fi

  umask 022
  {
    printf 'DOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$dr" "$rr" "$doc_dir"
    if [[ -n "$knowledge_type_in" ]]; then
      printf 'KNOWLEDGE_TYPE=%s\n' "$knowledge_type_in"
    fi
    if [[ -n "$agent_root_in" ]]; then
      ar="$(docsconfig_format_root_for_write "$agent_root_in")"
      printf 'AGENT_ROOT=%s\nAGENT_DIRS="%s"\n' "$ar" "$agent_dirs_in"
    fi
  } >"$out"
}

# 从文件解析 DOC_ROOT / REPO_ROOT / DOC_DIR（nameref 输出，Bash 5+）；可选 AGENT_ROOT / AGENT_DIRS
# 某键缺失则对应变量为空（兼容迁移场景）。
# *_ROOT 读入后展开为绝对路径；DOC_DIR、AGENT_DIRS 保持文件中的原始值。
#
# 用法：docsconfig_read_into <path> <nameref_doc_root> <nameref_repo_root> <nameref_doc_dir> \
#                            [<nameref_agent_root> <nameref_agent_dirs> [<nameref_knowledge_type>]]
# 返回：0=文件存在且已解析；1=文件不存在或不可读
# 说明：传入第 7 个 nameref 时写入 KNOWLEDGE_TYPE（无键则为空字符串）
docsconfig_read_into() {
  local path="${1:?path}"
  local -n _doc="${2:?}"
  local -n _repo="${3:?}"
  local -n _ddir="${4:?}"
  _doc=''; _repo=''; _ddir=''
  [[ -f "$path" ]] || return 1

  local raw_doc='' raw_repo='' raw_ddir='' raw_ar='' raw_ads='' raw_kt=''
  local line k v
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    case "$line" in
      DOC_ROOT=*|REPO_ROOT=*|DOC_DIR=*|AGENT_ROOT=*|AGENT_DIRS=*|KNOWLEDGE_TYPE=*)
        k="${line%%=*}"
        v="${line#*=}"
        v="${v%$'\r'}"
        # 去除 AGENT_DIRS 的外层引号
        if [[ "$k" == 'AGENT_DIRS' && ${#v} -ge 2 && "${v:0:1}" == '"' && "${v: -1}" == '"' ]]; then
          v="${v:1:${#v}-2}"
        fi
        case "$k" in
          DOC_ROOT)         raw_doc="$v"  ;;
          REPO_ROOT)        raw_repo="$v" ;;
          DOC_DIR)          raw_ddir="$v" ;;
          AGENT_ROOT)       raw_ar="$v"   ;;
          AGENT_DIRS)       raw_ads="$v"  ;;
          KNOWLEDGE_TYPE)   raw_kt="$v"   ;;
        esac
        ;;
    esac
  done <"$path"

  [[ -n "$raw_doc"  ]] && _doc="$(docsconfig_normalize_root_value "$raw_doc")"
  [[ -n "$raw_repo" ]] && _repo="$(docsconfig_normalize_root_value "$raw_repo")"
  _ddir="$raw_ddir"

  # 可选：解析 AGENT_ROOT / AGENT_DIRS（需传入第 5、6 个 nameref）
  if (( $# >= 6 )); then
    local -n _aroot="${5:?}"
    local -n _adirs="${6:?}"
    _aroot=''
    [[ -n "$raw_ar" ]] && _aroot="$(docsconfig_normalize_root_value "$raw_ar")"
    _adirs="$raw_ads"
  fi
  # 可选：KNOWLEDGE_TYPE（需传入第 7 个 nameref）
  if (( $# >= 7 )); then
    local -n _ktype="${7:?}"
    _ktype="$raw_kt"
  fi
  return 0
}

# 输出文件中匹配 KEY= 的行（调试 / 管道用）
# 用法：docsconfig_grep_keys <path>
docsconfig_grep_keys() {
  local path="${1:?path}"
  [[ -f "$path" ]] || return 1
  grep -E '^(DOC_ROOT|REPO_ROOT|DOC_DIR|AGENT_ROOT|AGENT_DIRS|KNOWLEDGE_TYPE)=' "$path" 2>/dev/null
}

# =============================================================================
# § 11  完成检查清单
# =============================================================================

# 输出初始化后的建议核对提示
# 用法：post_init_checklist [target_docs_dir]
post_init_checklist() {
  cat <<CHECKLIST

================================================================================
初始化完成！建议核对
================================================================================
CHECKLIST
}
# ========== docs-init-core.sh（工具与状态，内联）==========
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
  [mode]="${MODE:-standalone}"
  [type]="${TYPE:-}"
  [type_explicit]=0
  [scope]="${SCOPE:-knowledge}"
  [agents_opt]="${AGENTS_OPT:-cursor}"
  [dry_run]="0"
  [force]="${FORCE:-0}"
  [create_project_root]="${CREATE_PROJECT_ROOT:-0}"
  # 运行时填充
  [primary_agent_slash]=""
  [docs_slash]=""
  [central_app_id]=""
  [central_sys_id]=""
  [central_app_slug]=""
  [home_abs]=""
)

# 已启用的 Agent 列表
declare -a ENABLED_AGENTS=()

# 冲突处理全局策略（不放入 CFG，避免混淆）
_CONFLICT_MODE="${CONFLICT_PROMPT_MODE:-}"
_BACKUP_ROOT="${BACKUP_ROOT:-}"
_BACKUP_ROOT_AGENT="${BACKUP_ROOT_AGENT:-}"

# 本次运行共用时间戳（工程侧与 $HOME 侧备份目录保持一致）
DOC_INIT_STAMP=""

# =============================================================================
# § 3  工具函数（纯函数，无副作用）
# =============================================================================

have_cmd()  { command -v "$1" >/dev/null 2>&1; }
have_perl() { have_cmd perl; }

# 判断是否为文本文件（按扩展名或 MIME 类型）
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

# 返回 docs_abs 相对于 git_root 的路径（git_root 为空时返回绝对路径）
docs_rel_to_git_root() {
  local git_root docs_abs
  git_root="$(strip_trailing_slash "$1")"
  docs_abs="$(strip_trailing_slash "$2")"
  [[ -z "$git_root" ]] && { printf '%s' "$docs_abs"; return 0; }
  case "$docs_abs" in
    "$git_root")   printf '/'  ;;
    "$git_root"/*) printf '%s' "${docs_abs#"$git_root"}" ;;
    *)             printf '%s' "$docs_abs" ;;
  esac
}

# 从 git remote URL（或本地路径）提取仓库名（不含 .git）
git_remote_repo_basename() {
  local ref="$1"
  [[ -z "$ref" ]] && return 1
  # 已像本地路径无协议则当作目录名
  if [[ "$ref" == /* ]]; then
    printf '%s\n' "$(basename "$ref")"
    return 0
  fi
  # ssh: git@host:org/repo.git
  if [[ "$ref" =~ ^[a-zA-Z0-9._-]+@.*: ]]; then
    ref="${ref##*:}"
  fi
  # https://host/org/repo.git → repo
  ref="${ref##*/}"
  ref="${ref%.git}"
  printf '%s\n' "$ref"
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

# 判断本次运行是否需要安装 Agent（scripts / rules / skills）
needs_agent_install() {
  case "${CFG[scope]}" in
    agent) return 0 ;;
    *)     return 1 ;;
  esac
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

# 获取（或惰性初始化）工程文档侧备份根目录
get_backup_root() {
  if [[ -z "$_BACKUP_ROOT" ]]; then
    local stamp="${DOC_INIT_STAMP:-$(date +%Y-%m-%d_%H-%M-%S)}"
    _BACKUP_ROOT="${CFG[target_dir]:-$PWD}/.docs-init/${stamp}"
  fi
  printf '%s' "$_BACKUP_ROOT"
}

# 获取（或惰性初始化）Agent 安装目录侧备份根（~/.docs-init/<同一时间戳>/）
get_backup_root_agent() {
  if [[ -z "$_BACKUP_ROOT_AGENT" ]]; then
    local stamp="${DOC_INIT_STAMP:-$(date +%Y-%m-%d_%H-%M-%S)}"
    local home="${CFG[home_abs]:-}"
    [[ -n "$home" ]] || { printf ''; return 0; }
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
  # 避免同名冲突：追加 .__N 后缀
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
  [[ -f "$file" ]] && is_text_file "$file" || return 0
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

# 文档树替换：仅将 agent/ 前缀替换为目标 agent_slash
# 用法：rewrite_doc_file <file> <agent_slash>
rewrite_doc_file() {
  local file="$1" agent_slash="$2"
  [[ -f "$file" ]] && is_text_file "$file" || return 0
  have_perl || { warn "未安装 perl，跳过内容替换：$file"; return 0; }
  SDX_AGENT_SLASH="$agent_slash" \
    perl -CSD -i -pe 's{\bagent/}{$ENV{SDX_AGENT_SLASH}}g' \
    "$file" 2>/dev/null || true
}

# Agent 树替换：仅将 agent/ 前缀替换为目标 agent_slash（单文件）
# 用法：rewrite_agent_file <file> <agent_slash>
rewrite_agent_file() {
  local file="$1" agent_slash="$2"
  [[ -f "$file" ]] && is_text_file "$file" || return 0
  have_perl || return 0
  SDX_AGENT_SLASH="$agent_slash" \
    perl -CSD -i -pe 's{\bagent/}{$ENV{SDX_AGENT_SLASH}}g' \
    "$file" 2>/dev/null || true
}

# 对目录树下所有文件执行 Agent 树替换
# 用法：rewrite_agent_tree <root_dir> <agent_slash>
rewrite_agent_tree() {
  local root="$1" agent_slash="$2"
  [[ -d "$root" ]] || return 0
  local f
  while IFS= read -r -d '' f; do
    rewrite_agent_file "$f" "$agent_slash"
  done < <(find "$root" -type f -print0 2>/dev/null || true)
}


# ---- 占位：agent-init 不装知识库、不做 central；供下方统一主流程调用 ----
install_docs() { :; }
install_central() { :; }
# ========== Agent 安装（内联；maintain-agent-init.sh 中 AGENT_INSTALL_SH）==========
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

install_agent_scripts() {
  local agent agent_dir agent_slash
  local src_scripts src_docs_ssot dst_scripts

  src_scripts="${CFG[repo_root]}/agent/scripts"
  src_docs_ssot="${CFG[repo_root]}/scripts/docs-config.sh"

  [[ -d "$src_scripts" ]] || { warn "未找到 agent/scripts，跳过 Agent scripts"; return 0; }
  [[ -f "$src_docs_ssot" ]] || error "未找到 scripts/docs-config.sh: $src_docs_ssot"

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"

    info ">>> 安装 ${agent} Agent scripts（共享库）"
    info "    目录: ${agent_dir}/scripts"
    info "    agent/ → ${agent_slash}"

    dst_scripts="${agent_dir}/scripts"
    ensure_dir "$dst_scripts"

    local item base
    shopt -s nullglob
    for item in "$src_scripts"/*; do
      base="$(basename "$item")"
      [[ "$base" == 'docs-config.sh' ]] && continue
      if [[ -d "$item" ]]; then
        copy_dir "$item" "$dst_scripts/$base"
      else
        copy_file "$item" "$dst_scripts/$base"
      fi
    done

    copy_file "$src_docs_ssot" "$dst_scripts/docs-config.sh"

    if [[ "${CFG[dry_run]}" == '0' ]]; then
      rewrite_agent_tree "$dst_scripts" "$agent_slash"
    fi
  done
}

install_agent_skills() {
  local agent agent_dir agent_slash

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"

    info ">>> 安装 ${agent} Agent skills"
    info "    目录: ${agent_dir}"
    info "    agent/ → ${agent_slash}"

    ensure_dir "$agent_dir/skills"

    local -a skill_dirs=()
    local sd skill
    shopt -s nullglob
    for sd in "${CFG[repo_root]}/agent/skills"/*/; do
      [[ -d "$sd" ]] && skill_dirs+=("$sd")
    done

    if (( ${#skill_dirs[@]} == 0 )); then
      warn "未找到 agent/skills 下的技能子目录"
    else
      for sd in "${skill_dirs[@]}"; do
        skill="$(basename "$sd")"
        copy_dir "$sd" "$agent_dir/skills/$skill"
      done
    fi

    [[ -f "${CFG[repo_root]}/agent/skills/README.md" ]] \
      && copy_file "${CFG[repo_root]}/agent/skills/README.md" "$agent_dir/skills/README.md"

    if [[ "${CFG[dry_run]}" == '0' ]]; then
      rewrite_agent_tree "$agent_dir/skills" "$agent_slash"
    fi
  done
}

install_agent_rules() {
  local agent agent_dir agent_slash

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"

    info ">>> 安装 ${agent} Agent rules"
    info "    目录: ${agent_dir}"
    info "    agent/ → ${agent_slash}"

    ensure_dir "$agent_dir/rules"

    local rules_src="${CFG[repo_root]}/agent/rules"
    if [[ -d "$rules_src" ]]; then
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

    if [[ "${CFG[dry_run]}" == '0' ]]; then
      rewrite_agent_tree "$agent_dir/rules" "$agent_slash"
    fi
  done
}

install_agent() {
  case "${CFG[scope]}" in
    agent)
      install_agent_scripts
      install_agent_rules
      install_agent_skills
      ;;
  esac
}

# ========== .docsconfig 写入（内联）==========
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

# 写入目标工程仓库根 .docsconfig（按 scope 分支处理 DOC_* / AGENT_*）
# dry-run 时仅预览，不写入
install_docsconfig() {
  local doc_root='' repo_target='' dd=''
  local agent_root_in='' agent_dirs_str=''
  local old_doc_root='' old_repo_root='' old_doc_dir='' old_agent_root='' old_agent_dirs=''
  local old_knowledge_type=''
  local old_agent_root_line='' old_agent_dirs_line=''
  local cfg_file existed=0
  local kt_out=''

  # 判断 scope 类别
  local is_agent_scope=0 is_knowledge_scope=0
  case "${CFG[scope]}" in
    agent)               is_agent_scope=1     ;;
    config|knowledge) is_knowledge_scope=1 ;;
  esac

  # ── 推导 repo_target / doc_root / dd ──────────────────────────────────────
  if [[ "$is_agent_scope" == '1' ]]; then
    [[ -n "${CFG[home_abs]}" ]] || error "无法写入 .docsconfig：HOME 未就绪"
    resolve_docsconfig_roots repo_target doc_root dd
    agent_root_in="$repo_target"
  else
    # knowledge / config scope
    resolve_docsconfig_roots repo_target doc_root dd
  fi

  # ── 读取已有 .docsconfig（若存在）────────────────────────────────────────
  cfg_file="$repo_target/.docsconfig"
  if [[ -f "$cfg_file" ]]; then
    existed=1
    docsconfig_read_into "$cfg_file" old_doc_root old_repo_root old_doc_dir old_agent_root old_agent_dirs old_knowledge_type || true
    # 保留原始行，供 knowledge + 已存在 AGENT_ROOT 时原样写回
    local _line
    while IFS= read -r _line || [[ -n "$_line" ]]; do
      [[ -z "$_line" || "$_line" =~ ^[[:space:]]*# ]] && continue
      case "$_line" in
        AGENT_ROOT=*) old_agent_root_line="$_line" ;;
        AGENT_DIRS=*) old_agent_dirs_line="$_line" ;;
      esac
    done <"$cfg_file"
  fi

  if [[ "$existed" == '1' ]]; then
    info ".docsconfig 已存在，将按当前路径重算并覆盖写入: $cfg_file"
  else
    info ".docsconfig 不存在，将创建并写入: $cfg_file"
  fi

  # ── 确定 AGENT_ROOT（knowledge/config scope）──────────────────────────
  if [[ "$is_knowledge_scope" == '1' ]]; then
    if [[ -n "${CFG[docs_abs]}" ]]; then
      # config|knowledge：已有 AGENT_ROOT 则保留；否则默认为 ~（与仅装 Agent 未传文档目录时一致）
      if [[ -n "$old_agent_root" ]]; then
        agent_root_in="$old_agent_root"
        [[ "${CFG[scope]}" == 'knowledge' ]] && agent_dirs_str="$old_agent_dirs"
      else
        [[ -n "${CFG[home_abs]:-}" ]] || error "无法写入 AGENT_ROOT：HOME 未就绪"
        agent_root_in="${CFG[home_abs]}"
      fi
    elif [[ "${CFG[scope]}" == 'config' ]]; then
      agent_root_in="${CFG[home_abs]}"
    fi
  fi

  # ── 构建 AGENT_DIRS（agent / knowledge scope 均需要）─────────────────────
  if [[ "$is_agent_scope" == '1' || "$is_knowledge_scope" == '1' ]]; then
    local a d
    for a in "${ENABLED_AGENTS[@]}"; do
      d="$(get_agent_dir "$a")"
      agent_dirs_str="${agent_dirs_str:+$agent_dirs_str }$d"
    done
    # knowledge + docs + 旧文件存在时，优先保留旧 AGENT_DIRS，不按当前 --agents 覆盖
    if [[ "${CFG[scope]}" == 'knowledge' && -n "${CFG[docs_abs]}" && -n "$old_agent_root" ]]; then
      agent_dirs_str="$old_agent_dirs"
    fi
  fi

  # ── KNOWLEDGE_TYPE（knowledge / config scope 写入；agent 不写）────────────────
  if [[ "$is_knowledge_scope" == '1' ]]; then
    case "${CFG[scope]}" in
      knowledge) kt_out="${CFG[type]}" ;;
      config)
        if [[ -n "${old_knowledge_type:-}" ]]; then
          kt_out="$old_knowledge_type"
        else
          kt_out='application'
        fi
        ;;
    esac
  fi

  # ── 写入 ──────────────────────────────────────────────────────────────────
  if [[ "$is_agent_scope" == '1' || "$is_knowledge_scope" == '1' ]]; then
    if [[ "${CFG[scope]}" == 'knowledge' && -n "${CFG[docs_abs]}" && -n "$old_agent_root_line" ]]; then
      # knowledge + docs + 旧 AGENT_ROOT：AGENT_* 行原样保留，仅更新 DOC_* 与 KNOWLEDGE_TYPE
      local out dr rr
      out="$(strip_trailing_slash "$(abs_path "$repo_target")")/.docsconfig"
      dr="$(docsconfig_format_root_for_write "$doc_root")"
      rr="$(docsconfig_format_root_for_write "$repo_target")"
      if [[ -n "$kt_out" ]]; then
        docsconfig_validate_knowledge_type "$kt_out" || exit 1
      fi
      if [[ "${CFG[dry_run]}" == '1' ]]; then
        printf 'Would write %s:\nDOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$out" "$dr" "$rr" "$dd"
        [[ -n "$kt_out" ]] && printf 'KNOWLEDGE_TYPE=%s\n' "$kt_out"
        printf '%s\n' "$old_agent_root_line"
        [[ -n "$old_agent_dirs_line" ]] && printf '%s\n' "$old_agent_dirs_line"
      else
        umask 022
        {
          printf 'DOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$dr" "$rr" "$dd"
          [[ -n "$kt_out" ]] && printf 'KNOWLEDGE_TYPE=%s\n' "$kt_out"
          printf '%s\n' "$old_agent_root_line"
          [[ -n "$old_agent_dirs_line" ]] && printf '%s\n' "$old_agent_dirs_line"
        } >"$out"
      fi
    else
      docsconfig_write "$repo_target" "$doc_root" "$dd" "${CFG[dry_run]}" "$agent_root_in" "$agent_dirs_str" "${kt_out:-}"
    fi
  else
    docsconfig_write "$repo_target" "$doc_root" "$dd" "${CFG[dry_run]}"
  fi
}

# ========== parse_args（内联）==========
parse_args() {
  while (( $# > 0 )); do
    case "$1" in
      --mode=*)   CFG[mode]="${1#*=}";                        shift ;;
      --mode)     shift; CFG[mode]="${1:-}";                  shift ;;
      --scope=*)  CFG[scope]="${1#*=}";                       shift ;;
      --scope)    shift; CFG[scope]="${1:-}";                 shift ;;
      --type=*)   CFG[type]="${1#*=}"; CFG[type_explicit]=1;  shift ;;
      --type)     shift; CFG[type]="${1:-}"; CFG[type_explicit]=1; shift ;;
      --app-id=*|--app-id)
        error "--app-id 已移除：请使用 --mode=central --type=application|system（slug 自动推导）"
        ;;
      --agents=*) CFG[agents_opt]="${1#*=}";                  shift ;;
      --agents)
        shift
        local -a parts=()
        while (( $# > 0 )); do
          case "$1" in -*) break ;; *) parts+=("$1"); shift ;; esac
        done
        (( ${#parts[@]} > 0 )) || error "缺少 --agents 值（如 cursor,trea 或 cursor trea）"
        CFG[agents_opt]="$(IFS=','; printf '%s' "${parts[*]}")"
        ;;
      --dry-run)  CFG[dry_run]=1;                             shift ;;
      --force)    CFG[force]=1;                               shift ;;
      -r)         CFG[create_project_root]=1;                 shift ;;
      -h|--help)  usage; exit 0 ;;
      -*)         error "未知选项: $1" ;;
      *)
        [[ -z "${CFG[docs_abs]}" ]] \
          || error "多余的参数: $1（文档目录已指定为 ${CFG[docs_abs]}）"
        CFG[docs_abs]="$1"
        shift
        ;;
    esac
  done
}
# ========== 初始化校验与清单（内联）==========
# 初始化并校验 REPO_ROOT
init_repo_root() {
  if [[ -z "${CFG[repo_root]}" ]]; then
    CFG[repo_root]="$(abs_path "$SCRIPT_DIR/..")"
  fi
  [[ -d "${CFG[repo_root]}/application"    ]] || error "未找到 application 目录: ${CFG[repo_root]}/application"
  [[ -d "${CFG[repo_root]}/agent/skills"  ]] || error "未找到 agent/skills: ${CFG[repo_root]}/agent/skills"
  [[ -d "${CFG[repo_root]}/agent/rules"   ]] || error "未找到 agent/rules: ${CFG[repo_root]}/agent/rules"
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
  case "${CFG[scope]}" in
    ck)
      error "无效 --scope: ck（已移除，请使用 --scope=k 或 --scope=knowledge）" ;;
    c|config|cfg)    CFG[scope]='config'   ;;
    a|agent)         CFG[scope]='agent'    ;;
    k|knowledge)     CFG[scope]='knowledge' ;;
  esac

  case "${CFG[scope]}" in
    agent|knowledge|config) ;;
    *) error "无效 --scope: ${CFG[scope]}（支持 knowledge/k、agent/a、config/c）" ;;
  esac
}

# --scope=config|knowledge 时必须提供 <目标工程文档目录>
validate_docs_arg_for_scope() {
  case "${CFG[scope]}" in
    config|knowledge)
      [[ -n "${CFG[docs_abs]:-}" ]] \
        || error "--scope=${CFG[scope]} 时必须指定 <目标工程文档目录>（例：./scripts/knowledge-init.sh --scope=${CFG[scope]} ~/project/docs）"
      ;;
  esac
}

# 校验并应用 --agents
apply_agents() {
  validate_agents "${CFG[agents_opt]}" \
    || error "无效 --agents: ${CFG[agents_opt]}（支持 cursor、trea、claude、all 及逗号分隔组合）"
  read -ra ENABLED_AGENTS <<< "$(normalize_agents "${CFG[agents_opt]}")"
  (( ${#ENABLED_AGENTS[@]} > 0 )) || error "未解析到任何 Agent"
}

# 文档约定：--mode=central 仅在 scope=knowledge 时参与中央登记与默认 --type 推导
apply_mode_scope_policy() {
  case "${CFG[scope]}" in
    knowledge) ;;
    *)
      if [[ "${CFG[mode]}" == 'central' ]]; then
        warn "提示：--mode=central 仅在 scope=knowledge 时生效（中央登记）；当前 scope=${CFG[scope]}，已按 standalone 处理"
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

# 解析 --type（未显式指定时默认 application；central 仅允许 application|system）
resolve_type() {
  if [[ "${CFG[type_explicit]}" == '1' ]]; then
    CFG[type]="$(normalize_type "${CFG[type]}")"
    validate_type "${CFG[type]}" \
      || error "无效 --type: ${CFG[type]}（application(a)|system(s)|company(c)）"
  else
    CFG[type]='application'
  fi

  if [[ "${CFG[mode]}" == 'central' ]]; then
    case "${CFG[type]}" in
      application|system) ;;
      *) error "central 模式仅支持 --type=application|system（当前：${CFG[type]}）" ;;
    esac
  fi
}

# 校验 --type 对应的源目录存在
validate_type_sources() {
  case "${CFG[type]}" in
    application) [[ -d "${CFG[repo_root]}/application" ]] || error "未找到 application/: ${CFG[repo_root]}/application" ;;
    system)      [[ -d "${CFG[repo_root]}/system"      ]] || error "未找到 system/: ${CFG[repo_root]}/system（type=system）" ;;
    company)     [[ -d "${CFG[repo_root]}/company"     ]] || error "未找到 company/: ${CFG[repo_root]}/company（type=company）" ;;
  esac
}

# 计算运行时派生路径（primary_agent_slash / docs_slash）
compute_derived_paths() {
  CFG[primary_agent_slash]="$(get_agent_dir "${ENABLED_AGENTS[0]}")/"
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
  if [[ -n "${CFG[docs_abs]}" ]]; then
    log "初始化完成  目标: ${CFG[docs_abs]}"
  else
    log '初始化完成  目标: （未指定工程文档目录，仅更新用户主目录 Agent 配置）'
  fi
  log '─────────────────────────────────────────────────────────────────────────'
  if [[ -n "${CFG[docs_abs]}" ]]; then
    post_init_checklist "${CFG[docs_abs]}" >&2
  else
    post_init_checklist '<未指定工程文档目录>' >&2
  fi
}
# =============================================================================
# agent-init 专用：usage / 主流程
# =============================================================================

usage() {
  cat >&2 <<'EOF'
用法
  agent-init.sh [选项] [<目标工程文档目录>]

说明
  仅安装 Agent：从本仓库同步 agent/scripts（内含 docs-config.sh 副本）、agent/rules、agent/skills
  到各 Agent 目录；并写入 .docsconfig（DOC_* 与 AGENT_ROOT / AGENT_DIRS 等）。
  不拷贝 application/、system/、company/ 知识库模板；不执行 central 登记。知识库请用 ./scripts/knowledge-init.sh。

  <目标工程文档目录>（可选）
    文档根路径，例如 ~/workspace/my-app/docs。
    省略时：Agent 装入 $HOME 下 ~/.cursor、~/.trea、~/.claude，并在 $HOME 写 ~/.docsconfig。
    指定时：Agent 装入「文档父目录（工程根）」下对应目录，并在工程根写 .docsconfig。
    使用 -r 可在工程根尚不存在时自动创建。

选项
  --mode=MODE     standalone(s) | central(c)  [默认: s]（本脚本为 agent 流程；无知识库 central 登记）
  --scope=SCOPE   运行时会固定为 agent（与 knowledge-init 分流；勿用本脚本装知识库）
  --type=TYPE     仅为 CLI 兼容；本脚本不安装知识库
  --agents=LIST   cursor | trea | claude | all，逗号或空格分隔  [默认: cursor]
  --dry-run       预览，不写入文件
  --force         强制覆盖，不交互确认
  -r              允许工程根目录不存在时自动创建（传入 <目标工程文档目录> 时）
  -h, --help      显示此帮助

环境变量
  REPO_ROOT             本仓库（中央库）根目录（默认为本脚本所在仓库根）
  HOME                  未传文档目录时，Agent 的安装位置基准
  CREATE_PROJECT_ROOT   等同 -r
  FORCE                 1 等同 --force

示例
  ./scripts/agent-init.sh
  ./scripts/agent-init.sh --agents=cursor,claude
  ./scripts/agent-init.sh ~/workspace/my-app/docs
  ./scripts/agent-init.sh --dry-run ~/workspace/my-app/docs
EOF
}

agent_init_run() {
  CFG[scope]=agent
  init_repo_root
  validate_sync_scope
  validate_docs_arg_for_scope
  apply_mode
  apply_mode_scope_policy
  apply_type_scope_policy
  resolve_type

  validate_type_sources

  if [[ -z "${CFG[docs_abs]}" ]]; then
    [[ "${CFG[mode]}" != 'central' ]] || error "central 模式必须指定 <目标工程文档目录>"
  fi

  [[ -n "${CFG[docs_abs]}" ]] && validate_docs_and_target

  apply_agents
  compute_derived_paths
  DOC_INIT_STAMP="$(date +%Y-%m-%d_%H-%M-%S)"

  if needs_agent_install || [[ -z "${CFG[docs_abs]}" ]]; then
    [[ -n "${HOME:-}" ]] || error "需要 HOME 环境变量"
    CFG[home_abs]="$(abs_path "$HOME")"
  fi

  if [[ -z "${CFG[docs_abs]}" ]] && needs_agent_install; then
    warn "未指定工程文档目录：Agent 配置中的文档前缀将按默认值处理；若需与真实目录一致请传入 <目标工程文档目录>"
  fi

  have_perl || warn "未检测到 perl：文件内容替换将被跳过，建议安装 perl。"

  if should_reset_docs_dir_before_sync; then
    reset_docs_dir_with_backup
  fi

  if [[ -n "${CFG[docs_abs]}" && "${CFG[scope]}" == 'knowledge' ]]; then
    install_docs
  fi

  if [[ "${CFG[mode]}" == 'central' ]]; then
    install_central
  fi

  install_agent

  if [[ -n "${CFG[docs_abs]}" ]] || needs_agent_install; then
    [[ -n "${CFG[home_abs]:-}" ]] || { [[ -n "${HOME:-}" ]] && CFG[home_abs]="$(abs_path "$HOME")"; }
    install_docsconfig
  fi

  info "完成：初始化"
  print_checklist
}

main() {
  parse_args "$@"
  agent_init_run
}

main "$@"
