#!/usr/bin/env bash
#
# docs-config.sh — SDX 知识库初始化配置模块
#
# 职责：
#   提供知识库初始化脚本的共享常量、默认值与校验/工具函数。
#   作为配置层，集中管理所有可配置参数及其合法取值。
#
# 设计原则：
#   - 单一事实源：所有默认值、支持的模式、校验逻辑集中在此
#   - 可扩展：新增配置只需修改此处，无需改动业务脚本
#   - 可验证：提供校验函数确保外部输入合法
#   - 纯函数优先：路径/校验函数无副作用，便于测试
#
# 依赖：Bash 5+（关联数组、nameref）
#
# 使用方式（被 source，不直接执行）：
#   source "$(dirname "$0")/docs-config.sh"
#

# =============================================================================
# § 0  环境前置检查
# =============================================================================

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

readonly SDX_VERSION='2.3.0'
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
# 输出：Agent 目录名（如 .cursor）；未知 agent 回退 .agent
get_agent_dir() {
  printf '%s' "${SDX_AGENT_DIR_MAP[${1:-}]:-.agent}"
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

# 写入 $REPO_ROOT/.docsconfig（至少三键；可选 AGENT_*）
# 用法：docsconfig_write <repo_root_abs> <doc_root_abs> <doc_dir> <dry_run:0|1> \
#                        [agent_root_abs] [agent_dirs_space_separated]
# 说明：agent_root_abs 非空时追加 AGENT_ROOT= 与 AGENT_DIRS="..."
docsconfig_write() {
  local repo_root="${1:?repo_root}"
  local doc_root="${2:?doc_root}"
  local doc_dir="${3:?doc_dir}"
  local dry="${4:-0}"
  local agent_root_in="${5:-}"
  local agent_dirs_in="${6:-}"

  local out rr dr ar
  out="$(strip_trailing_slash "$(abs_path "$repo_root")")/.docsconfig"
  rr="$(docsconfig_format_root_for_write "$repo_root")"
  dr="$(docsconfig_format_root_for_write "$doc_root")"

  # dry-run：仅预览，不写入
  if [[ "$dry" == '1' ]]; then
    printf 'Would write %s:\nDOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$out" "$dr" "$rr" "$doc_dir"
    if [[ -n "$agent_root_in" ]]; then
      ar="$(docsconfig_format_root_for_write "$agent_root_in")"
      printf 'AGENT_ROOT=%s\nAGENT_DIRS="%s"\n' "$ar" "$agent_dirs_in"
    fi
    return 0
  fi

  umask 022
  {
    printf 'DOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$dr" "$rr" "$doc_dir"
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
#                            [<nameref_agent_root> <nameref_agent_dirs>]
# 返回：0=文件存在且已解析；1=文件不存在或不可读
docsconfig_read_into() {
  local path="${1:?path}"
  local -n _doc="${2:?}"
  local -n _repo="${3:?}"
  local -n _ddir="${4:?}"
  _doc=''; _repo=''; _ddir=''
  [[ -f "$path" ]] || return 1

  local raw_doc='' raw_repo='' raw_ddir='' raw_ar='' raw_ads=''
  local line k v
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    case "$line" in
      DOC_ROOT=*|REPO_ROOT=*|DOC_DIR=*|AGENT_ROOT=*|AGENT_DIRS=*)
        k="${line%%=*}"
        v="${line#*=}"
        v="${v%$'\r'}"
        # 去除 AGENT_DIRS 的外层引号
        if [[ "$k" == 'AGENT_DIRS' && ${#v} -ge 2 && "${v:0:1}" == '"' && "${v: -1}" == '"' ]]; then
          v="${v:1:${#v}-2}"
        fi
        case "$k" in
          DOC_ROOT)   raw_doc="$v"  ;;
          REPO_ROOT)  raw_repo="$v" ;;
          DOC_DIR)    raw_ddir="$v" ;;
          AGENT_ROOT) raw_ar="$v"   ;;
          AGENT_DIRS) raw_ads="$v"  ;;
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
  return 0
}

# 输出文件中匹配 KEY= 的行（调试 / 管道用）
# 用法：docsconfig_grep_keys <path>
docsconfig_grep_keys() {
  local path="${1:?path}"
  [[ -f "$path" ]] || return 1
  grep -E '^(DOC_ROOT|REPO_ROOT|DOC_DIR|AGENT_ROOT|AGENT_DIRS)=' "$path" 2>/dev/null
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
