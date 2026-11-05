#!/usr/bin/env bash
# forbidden-ref-outer.sh — 库外禁止的文件引用（当前：superpowers 具体文件）
# 在仓库根执行：bash agent/scripts/tools/forbidden-ref-outer.sh
# 规则见 agent/rules/CONVENTIONS.md §superpowers 引用隔离

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/docsconfig.sh"
docsconfig_bootstrap_validate
repo_abs="$(docsconfig_repo_abs)"

# 配置校验沿用共享入口；扫描独立于 Git 忽略规则。
exec python3 "$SCRIPT_DIR/forbidden_file_refs.py" "$repo_abs"
