#!/usr/bin/env bash
set -euo pipefail

# Bash 入口只负责参数与共享配置；文档检查使用 Python 3 标准库。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
用法：bash validate-prd.sh [--file <path>] | --help
  --file  按调用目录解析文件；不依赖 .docsconfig。
  无参数  读取当前工程 .docsconfig，扫描 DOC_DIR/requirements/PRD-*.md。
依赖：Bash 5+、Python 3.8+（标准库）。只读，不改原文。
frontmatter 子集：顶层标量；单引号；双引号（JSON 转义）；reviewers 字符串列表。
支持行尾注释、reviewers 行内/缩进列表、UTF-8 BOM 与 CRLF。
不支持嵌套映射、多行标量、锚点/别名或标签；遇到时明确报错。
退出码：0=结构通过或扫描无目标；1=文档错误；2=用法/环境错误。
无目标会标记 NOT_VALIDATED（未校验）；结构通过不等于语义验收。
EOF
}

if [[ $# -eq 1 && "$1" == --help ]]; then
  usage
  exit 0
fi
if [[ $# -ne 0 && ( $# -ne 2 || "$1" != --file || -z "${2:-}" || "${2:-}" == --* ) ]]; then
  printf '[ERROR] 参数错误；使用 --help 查看用法。\n' >&2
  exit 2
fi
if ! command -v python3 >/dev/null 2>&1; then
  printf '[ERROR] 需要 Python 3.8+。\n' >&2
  exit 2
fi
if [[ $# -eq 2 ]]; then
  exec python3 "$SCRIPT_DIR/validate_prd.py" --file "$2"
fi

# 显式检查失败，统一映射配置/环境错误为 2；不切换调用目录。
if ! doc_abs="$(
  source "$SCRIPT_DIR/../../../scripts/lib/docsconfig.sh" || exit 2
  docsconfig_bootstrap_validate || exit 2
  docsconfig_doc_abs || exit 2
)"; then
  exit 2
fi
exec python3 "$SCRIPT_DIR/validate_prd.py" --scan-root "$doc_abs/requirements"
