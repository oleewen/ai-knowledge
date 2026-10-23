#!/usr/bin/env bash
# lib/knowledge-link-paths.sh — 清单所属工作区、路径编解码与真实路径边界。
# 依赖由 knowledge-links.sh 提供；不设置独立加载哨兵。

# 与 identity 解析一致：判定是否为 Git 远端 URL 形态（path 字段禁止写入此类串）
knowledge_link_value_looks_like_git_remote() {
  [[ "${1:-}" =~ ^(git@|ssh://|https://|http://) ]]
}

# 每份清单从所属库配置解析工作区；不读取环境中的 WORK_SPACE。
knowledge_links_workspace_for_file() {
  local f="${1:?}" owner cfg rd='' dd='' ar='' kt='' ad=''
  owner="$(dirname "$(abs_path "$f")")"
  while [[ ! -f "$owner/.docsconfig" ]]; do
    [[ "$owner" != / ]] || { error "knowledge-links 缺少所属库 .docsconfig: $f"; return 1; }
    owner="$(dirname "$owner")"
  done
  cfg="$owner/.docsconfig"
  docsconfig_read_into "$cfg" rd dd ar kt ad || return 1
  [[ -n "$ar" && -n "$ad" ]] || { error "knowledge-links 配置缺少 AGENT_ROOT/AGENT_DIR: $cfg"; return 1; }
  docsconfig_load_workspace_abs "$ar" "$ad"
}

# 规范化真实路径（含尚不存在的 clone 目标），校验目录边界和符号链接。
_knowledge_link_relative_to_workspace() {
  python3 - "$1" "$2" "${3:-relative}" <<'PY_PATH'
import sys
from pathlib import Path
try:
    target = Path(sys.argv[1]).expanduser().resolve()
    workspace = Path(sys.argv[2]).expanduser().resolve()
    relative = target.relative_to(workspace)
    print(target if sys.argv[3] == "absolute" else relative.as_posix())
except (ValueError, OSError, RuntimeError) as exc:
    print(f"knowledge-links: path 必须位于 WORK_SPACE 内: {sys.argv[1]} ({exc})", file=sys.stderr)
    sys.exit(1)
PY_PATH
}

knowledge_links_validate_stored_path_field() {
  local p="${1:?}" src="${2:?}"
  if knowledge_link_value_looks_like_git_remote "$p"; then
    error "knowledge-links.yaml: path 不得为远程 URL；远端请写入 repository: $src"
    return 1
  fi
  case "$p" in
    '${WORK_SPACE}'|'${WORK_SPACE}/'*) ;;
    *) error "knowledge-links.yaml: path 必须使用字面量 \${WORK_SPACE}/…，请迁移旧路径: $src"; return 1 ;;
  esac
}

knowledge_link_expand_stored_path() {
  local p="${1:?}" f="${2:?knowledge-links 文件路径必填}" ws suffix
  knowledge_links_validate_stored_path_field "$p" "$f" || return 1
  ws="$(knowledge_links_workspace_for_file "$f")" || return 1
  suffix="${p#'${WORK_SPACE}'}"
  _knowledge_link_relative_to_workspace "${ws%/}/${suffix#/}" "$ws" absolute
}

_knowledge_link_store_with_workspace() {
  local rel
  rel="$(_knowledge_link_relative_to_workspace "${1:?}" "${2:?}")" || return 1
  if [[ "$rel" == . ]]; then
    printf '%s\n' '${WORK_SPACE}'
  else
    printf '${WORK_SPACE}/%s\n' "$rel"
  fi
}

# 写入只生成 WORK_SPACE 占位符；第二参数为接收此 path 的清单。
knowledge_link_stored_path_from_absolute() {
  local ws
  ws="$(knowledge_links_workspace_for_file "${2:?knowledge-links 文件路径必填}")" || return 1
  _knowledge_link_store_with_workspace "${1:?}" "$ws"
}
