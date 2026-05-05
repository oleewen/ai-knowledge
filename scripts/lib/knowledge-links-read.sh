# knowledge-links-read.sh — 解析 knowledge-links.yaml（只读；由调用方 source；set 由调用方负责）
# 若已由调用方 source link-config.sh 则跳过，避免 LINK_CONFIG_DIR 等 readonly 重复赋值
# shellcheck source=../link-config.sh
if [[ -z "${LINK_CONFIG_DIR:-}" ]]; then
  source "${BASH_SOURCE[0]%/*}/../link-config.sh"
fi

# =============================================================================
# knowledge-links.yaml
# =============================================================================

# 去除 YAML 字段值两端的单/双引号
_yaml_unquote() {
  local v="${1:-}"
  v="${v#\"}"; v="${v%\"}"
  v="${v#\'}"; v="${v%\'}"
  printf '%s' "$v"
}

# 与 identity 解析一致：判定是否为 Git 远端 URL 形态（path 字段禁止写入此类串）
knowledge_link_value_looks_like_git_remote() {
  [[ "${1:-}" =~ ^(git@|ssh://|https://|http://) ]]
}

# path 字段禁止为远程 URL 形态（须写在 repository）
knowledge_links_validate_stored_path_field() {
  local p="${1:?}" src="${2:?}"
  [[ -n "$p" ]] || sdx_error "knowledge-links.yaml 条目缺少 path 或 path 为空: $src"
  if knowledge_link_value_looks_like_git_remote "$p"; then
    sdx_error "knowledge-links.yaml: path 不得为远程 URL（已废弃）。请将远端写入 repository，path 改为 ~/…、~/ 或本机绝对路径（兼容旧：无 ~ 的 \$HOME 相对片段）: $src"
  fi
}

# 将登记 path 展开为绝对路径（~/…、~、/ 绝对路径走 abs_path；否则视为相对 $HOME 的旧形态并拼 $HOME）
knowledge_link_expand_stored_path() {
  local p="${1:?}" home
  if [[ "$p" == /* ]]; then
    abs_path "$p"
    return 0
  fi
  if [[ "$p" == '~' ]] || [[ "$p" =~ ^~/ ]]; then
    abs_path "$p"
    return 0
  fi
  home="${HOME:-}"
  [[ -n "$home" ]] || sdx_error "未设置 HOME，无法展开相对 path: $p"
  abs_path "${home%/}/$p"
}

# 读入 knowledge-links.yaml 填入数组（下标对齐）；非法旧形态 path=URL 时报错退出
knowledge_links_load_into_arrays() {
  local f="${1:?}"
  local -n _paths="${2:?}"
  local -n _repos="${3:?}"
  local -n _dirs="${4:?}"
  local -n _apps="${5:?}"
  local -n _labels="${6:?}"
  local line key val path="" repo="" doc_dir="" app_name="" app_label=""

  _paths=()
  _repos=()
  _dirs=()
  _apps=()
  _labels=()

  [[ -f "$f" ]] || return 0

  knowledge_links_flush_pending() {
    if [[ -n "$path" ]]; then
      knowledge_links_validate_stored_path_field "$path" "$f"
      _paths+=("$path")
      _repos+=("${repo:-}")
      _dirs+=("${doc_dir:-}")
      _apps+=("${app_name:-}")
      _labels+=("${app_label:-}")
    elif [[ -n "$repo$doc_dir$app_name$app_label" ]]; then
      sdx_error "knowledge-links.yaml 中存在未写完的条目（有 repository/doc_dir/app_name/app_label 但缺少 path）: $f"
    fi
    path=''
    repo=''
    doc_dir=''
    app_name=''
    app_label=''
  }

  # 未知键静默忽略（与 YAML 扩展字段前向兼容）
  knowledge_links_set_kv() {
    case "${1:?}" in
      path) path="$2" ;;
      repository) repo="$2" ;;
      doc_dir) doc_dir="$2" ;;
      app_name) app_name="$2" ;;
      app_label) app_label="$2" ;;
      *) ;;
    esac
  }

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+([a-z_]+):[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="$(_yaml_unquote "${BASH_REMATCH[2]}")"
      knowledge_links_flush_pending
      knowledge_links_set_kv "$key" "$val"
    elif [[ "$line" =~ ^[[:space:]]{4}([a-z_]+):[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="$(_yaml_unquote "${BASH_REMATCH[2]}")"
      knowledge_links_set_kv "$key" "$val"
    fi
  done <"$f"
  knowledge_links_flush_pending
}
