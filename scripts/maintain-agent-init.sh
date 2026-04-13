#!/usr/bin/env bash
# 从 SSOT（docs-config.sh、docs-init-core.sh）及下方内嵌的 Agent 安装段重新生成 agent-init.sh。
# 修改 docs-config / core 中与 agent 相关的函数后，运行：bash scripts/maintain-agent-init.sh
#
# 维护策略：已选 A（双份实现 + SSOT 对照）；勿期待与 knowledge-init 自动同步，改 SSOT 后须手动对齐 knowledge-init 内联并本脚本再生成。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT

python3 << 'PY'
import os
from pathlib import Path
root = Path(os.environ["ROOT"])
cfg_lines = (root / "docs-config.sh").read_text().splitlines()
core_lines = (root / "lib/docs-init-core.sh").read_text().splitlines()

# Agent 安装段：与已删除的 lib/agent-init-install.sh 同源；若改此处须同步行为说明于 scripts/README.md
AGENT_INSTALL_SH = r'''
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
'''

cfg_block = "\n".join(cfg_lines[24:551])
# 从 §1 log 起，跳过 §0 的 [[ -f docs-config ]] / source（内联 docs-config 后不可重复 source）
core_tools = "\n".join(core_lines[29:457])
docscfg = "\n".join(core_lines[787:942])
parse_args = "\n".join(core_lines[1016:1052])
rest = "\n".join(core_lines[1058:1217])
agent_funcs = AGENT_INSTALL_SH.strip() + "\n"

header = r'''#!/usr/bin/env bash
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

'''

stubs = '''
# ---- 占位：agent-init 不装知识库、不做 central；供下方统一主流程调用 ----
install_docs() { :; }
install_central() { :; }
'''

glue = r'''
# =============================================================================
# agent-init 专用：usage / 主流程
# =============================================================================

usage() {
  cat >&2 <<'EOF'
用法
  agent-init.sh [选项] [<目标工程文档目录>]

说明
  安装中央库 agent/scripts（含 docs-config.sh SSOT）、agent/rules、agent/skills 到各 Agent 目录；
  并写入目标工程（或 $HOME）侧 .docsconfig。未指定文档目录时装入 $HOME/.cursor 等。

选项
  --mode=MODE     standalone(s) | central(c)（agent 流程下 central 会降级为 standalone）
  --agents=LIST   cursor | trea | claude | all
  --dry-run       预览
  --force         强制覆盖
  -r              允许自动创建工程根
  -h, --help      帮助

环境变量
  REPO_ROOT       中央库根目录（默认为本脚本所在仓库根）

示例
  ./scripts/agent-init.sh
  ./scripts/agent-init.sh ~/project/docs
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
'''

full = "\n".join([
  header.rstrip(),
  "# ========== docs-config.sh（内联）==========",
  cfg_block,
  "# ========== docs-init-core.sh（工具与状态，内联）==========",
  core_tools,
  stubs.rstrip(),
  "# ========== Agent 安装（内联；maintain-agent-init.sh 中 AGENT_INSTALL_SH）==========",
  agent_funcs,
  "# ========== .docsconfig 写入（内联）==========",
  docscfg,
  "# ========== parse_args（内联）==========",
  parse_args,
  "# ========== 初始化校验与清单（内联）==========",
  rest,
  glue.strip(),
]) + "\n"

out = root / "agent-init.sh"
out.write_text(full)
print("Wrote", out, "lines", len(full.splitlines()))
PY

bash -n "$ROOT/agent-init.sh"
echo "OK: agent-init.sh regenerated and bash -n passed"
