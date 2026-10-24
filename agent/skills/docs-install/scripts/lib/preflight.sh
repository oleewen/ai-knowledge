#!/usr/bin/env bash
# docs-install 私有预检：完整解析计划，所有函数均不得写文件。

# pathlib.resolve 同时处理未存在的路径、.. 与符号链接，不创建占位目录。
docs_install_absolute_path() {
  python3 - "$1" <<'PY'
import sys
from pathlib import Path

try:
    path = Path(sys.argv[1]).expanduser().resolve()
    for parent in path.parents:
        if parent.exists() and not parent.is_dir():
            raise ValueError(f"父路径不是目录: {parent}")
    print(path)
except (OSError, RuntimeError, ValueError) as exc:
    print(f"无法解析路径: {exc}", file=sys.stderr)
    sys.exit(1)
PY
}

docs_install_plan_target() {
  CFG[docs_abs]="$(docs_install_absolute_path "${CFG[docs_abs]}")"
  [[ "${CFG[docs_abs]}" != / ]] || error '目标文档目录不能是文件系统根'
  [[ ! -e "${CFG[docs_abs]}" || -d "${CFG[docs_abs]}" ]] \
    || error "目标已存在但不是目录: ${CFG[docs_abs]}"
  CFG[target_dir]="$(dirname "${CFG[docs_abs]}")"
  CFG[doc_dir]="$(basename "${CFG[docs_abs]}")"
  CFG[repo_dir]="$(basename "${CFG[target_dir]}")"
  docsconfig_validate_repo_dir "${CFG[repo_dir]}"
  docsconfig_validate_doc_dir "${CFG[doc_dir]}"
  [[ -d "${CFG[target_dir]}" || "${CFG[create_project_root]}" == 1 ]] \
    || error "工程根目录不存在: ${CFG[target_dir]}（请先创建，或使用 -r）"
  if [[ -d "${CFG[docs_abs]}" ]]; then
    local git_root
    git_root="$(git -C "${CFG[docs_abs]}" rev-parse --show-toplevel 2>/dev/null || true)"
    [[ "$git_root" != "${CFG[docs_abs]}" ]] || error '文档目录不能是 Git 仓库根；--target 须为文档子目录'
  fi
}

docs_install_plan_config() {
  local rd='' dd='' ar='' kt='' ad='' selected_root='' selected_dir=''
  CFG[config_file]="${CFG[target_dir]}/.docsconfig"
  if [[ -f "${CFG[config_file]}" ]]; then
    docsconfig_read_into "${CFG[config_file]}" rd dd ar kt ad
  fi
  docsconfig_fill_agent_fields selected_root selected_dir "$ar" "$ad" "${CFG[home_abs]}" \
    || error '无法补全 AGENT_ROOT/AGENT_DIR（请先 /agent-install 或修正 .docsconfig）'
  CFG[agent_root]="$selected_root"
  CFG[agent_dir]="$selected_dir"
}

# 目录名称在大小写不敏感磁盘上不唯一；用现存祖先 inode 识别真实包含关系。
# 未存在的目标由最近现存祖先向上比较，不通过 lower() 猜测文件系统语义。
docs_install_validate_source_boundary() {
  python3 - "${CFG[source_dir]}" "${CFG[docs_abs]}" "${CFG[repo_root]}" <<'PY'
import sys
from pathlib import Path


def contains(parent: Path, child: Path) -> bool:
    try:
        parent_inode = parent.stat()
    except FileNotFoundError:
        return False
    for ancestor in (child, *child.parents):
        try:
            ancestor_inode = ancestor.stat()
        except FileNotFoundError:
            continue
        if (parent_inode.st_dev, parent_inode.st_ino) == (ancestor_inode.st_dev, ancestor_inode.st_ino):
            return True
    return False


try:
    source, target, meta = map(Path, sys.argv[1:])
    if contains(target, meta):
        raise ValueError(f"目标目录包含元库根，拒绝重装: {meta} / {target}")
    if contains(source, target) or contains(target, source):
        raise ValueError(f"源与目标目录重叠，拒绝重装: {source} / {target}")
except (OSError, RuntimeError, ValueError) as exc:
    print(f"错误: {exc}", file=sys.stderr)
    sys.exit(1)
PY
}

docs_install_plan_source() {
  if [[ -z "${CFG[repo_root]}" ]]; then
    CFG[repo_root]="$(docs_install_absolute_path "$SCRIPT_DIR/../../../..")"
    [[ -d "${CFG[repo_root]}/agent/skills/docs-install" ]] \
      || error '安装副本执行 knowledge 须传 --meta <元库根目录>'
  else
    CFG[repo_root]="$(docs_install_absolute_path "${CFG[repo_root]}")"
  fi
  CFG[source_dir]="$(docs_install_absolute_path "${CFG[repo_root]}/${CFG[type]}")"
  [[ -d "${CFG[source_dir]}" ]] || error "未找到 ${CFG[type]} 目录: ${CFG[source_dir]}"
  docs_install_validate_source_boundary
  CFG[meta_repo]="$(knowledge_link_git_remote_url_prefer_origin "${CFG[repo_root]}" || true)"
  [[ -n "${CFG[meta_repo]}" ]] || error "元知识库缺少 Git remote URL: ${CFG[repo_root]}"
}

docs_install_plan_links() {
  local workspace paths=() repos=() dirs=() names=() labels=() types=() i
  knowledge_links_validate_file_target "${CFG[docs_abs]}/knowledge-links.yaml" || return 1
  workspace="$(docsconfig_load_workspace_abs "${CFG[agent_root]}" "${CFG[agent_dir]}")"
  _knowledge_link_relative_to_workspace "${CFG[target_dir]}" "$workspace" >/dev/null
  CFG[meta_path_stored]="$(_knowledge_link_store_with_workspace "${CFG[repo_root]}" "$workspace")"
  if [[ -f "${CFG[docs_abs]}/knowledge-links.yaml" ]]; then
    knowledge_links_load_into_arrays "${CFG[docs_abs]}/knowledge-links.yaml" paths repos dirs names labels types
    for i in "${!paths[@]}"; do
      [[ -n "${repos[i]}" ]] || error 'knowledge-links.yaml 条目缺少 repository'
      [[ "${types[i]}" == meta || -n "${names[i]}" ]] || error 'knowledge-links.yaml 的 parent/child 条目缺少 name'
    done
  fi
}

docs_install_preflight() {
  have_cmd python3 || error '需要 Python 3（用于未存在路径与符号链接解析）'
  [[ -n "${HOME:-}" ]] || error '需要 HOME 环境变量'
  CFG[home_abs]="$(docs_install_absolute_path "$HOME")"
  docs_install_plan_target
  docs_install_plan_config
  [[ "${CFG[scope]}" == knowledge ]] || return 0
  have_perl || error 'knowledge 安装需要 Perl（用于路径改写）；当前未写入'
  docs_install_plan_source
  docs_install_plan_links
  if [[ -d "${CFG[docs_abs]}" && "${CFG[dry_run]}" == 0 && "${CFG[force]}" != 1 ]]; then
    local first_entry
    first_entry="$(find "${CFG[docs_abs]}" -mindepth 1 -maxdepth 1 -print -quit)"
    [[ -z "$first_entry" ]] || error 'DOC_DIR 非空；重装会备份并清空，请明确传入 --force'
  fi
}
