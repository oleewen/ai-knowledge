#!/usr/bin/env bash
# docs-install 私有 CLI：只解析、规范化参数，不写文件。

docs_install_usage() {
  cat <<'EOF'
用法：docs-install.sh --target PATH [选项]

  --target PATH   目标工程文档子目录（必填）
  --scope SCOPE   knowledge(k，默认) | config(c/cfg)
  --type TYPE     application(a，默认) | system(s) | solution(sln) | company(c)
  --mode MODE     standalone(s，默认) | central(c，仅 application)
  --meta PATH     元库根；源码布局默认本仓，安装副本的 knowledge 必填
  --force        允许备份并重装非空 DOC_DIR
  -r             允许创建缺失的工程根目录
  --dry-run      完整预览，不创建目录、不改写文件或软链
  -h, --help     显示帮助

参数均兼容 --name=value。值不得为空或以 - 开头；此类路径请写 ./ 前缀。
config 仅重写 .docsconfig 路径键和 AGENT_*，不保留 KNOWLEDGE_TYPE，不创建 DOC_DIR。
knowledge 同步模板、写 KNOWLEDGE_TYPE、保留现有建联并更新 type:meta。
central 仅分发 application 的 knowledge/、specs/ 和根部入口文件。
依赖：Bash 5+、Python 3、Git；Perl 用于安装后路径改写。
本机须先有 Agent 安装树；knowledge 另须其 configs 中有 WORK_SPACE。
环境默认值：SCOPE、MODE、FORCE=1、CREATE_PROJECT_ROOT=1。

示例：
  docs-install.sh --target ~/workspaces/app/docs --dry-run
  docs-install.sh --scope=config --target ~/workspaces/app/docs --dry-run
  docs-install.sh --meta ~/workspaces/ai-knowledge --type=solution --target ~/workspaces/sln/docs --dry-run
EOF
}

docs_install_require_value() {
  [[ -n "${2:-}" && "$2" != -* ]] || error "缺少或无效 ${1} 值（不得为空或以 - 开头）"
}

docs_install_parse_args() {
  local option value
  while (( $# )); do
    case "$1" in
      --target|--scope|--type|--mode|--meta)
        option="$1"; shift
        value="${1:-}"
        docs_install_require_value "$option" "$value"
        shift
        ;;
      --target=*|--scope=*|--type=*|--mode=*|--meta=*)
        option="${1%%=*}"; value="${1#*=}"
        docs_install_require_value "$option" "$value"
        shift
        ;;
      --dry-run) CFG[dry_run]=1; shift; continue ;;
      --force) CFG[force]=1; shift; continue ;;
      -r) CFG[create_project_root]=1; shift; continue ;;
      -h|--help) docs_install_usage; exit 0 ;;
      *) cli_unknown_arg "$1" ;;
    esac
    case "$option" in
      --target) CFG[docs_abs]="$value" ;;
      --meta) CFG[repo_root]="$value" ;;
      --type) CFG[type]="$value"; CFG[type_explicit]=1 ;;
      --scope) CFG[scope]="$value" ;;
      --mode) CFG[mode]="$value" ;;
    esac
  done
  [[ -n "${CFG[docs_abs]}" ]] || error '缺少必填参数：--target <目标工程文档目录>'
  validate_scope "${CFG[scope]}" || error "无效 --scope: ${CFG[scope]}（knowledge/k、config/c/cfg）"
  CFG[scope]="$(normalize_scope "${CFG[scope]}")"
  validate_mode "${CFG[mode]}" || error "无效 --mode: ${CFG[mode]}（standalone/s、central/c）"
  CFG[mode]="$(normalize_mode "${CFG[mode]}")"
  if [[ "${CFG[scope]}" == config ]]; then
    [[ "${CFG[type_explicit]}" == 0 ]] || warn '--type 仅在 scope=knowledge 时生效；已忽略'
    [[ "${CFG[mode]}" != central ]] || warn '--mode=central 仅在 scope=knowledge 时生效；已按 standalone 处理'
    CFG[type]=application
    CFG[mode]=standalone
  else
    CFG[type]="$(normalize_type "${CFG[type]}")"
    validate_type "${CFG[type]}" || error "无效 --type: ${CFG[type]}（application、system、solution、company）"
    [[ "${CFG[mode]}" != central || "${CFG[type]}" == application ]] \
      || error "--mode=central 仅支持 --type=application（当前：${CFG[type]}）"
  fi
}
