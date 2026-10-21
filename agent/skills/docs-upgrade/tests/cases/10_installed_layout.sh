#!/usr/bin/env bash
# 在临时 .agents 布局运行测试入口，验证脚本模块及测试路径不依赖仓库 agent/ 名称。
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
INSTALL_AGENT="$TMP_DIR/.agents"
INSTALL_SKILL="$INSTALL_AGENT/skills/docs-upgrade"
mkdir -p "$INSTALL_SKILL/tests/cases"
cp -R "$DOCS_UPGRADE_AGENT_DIR/scripts" "$INSTALL_AGENT/scripts"
cp -R "$DOCS_UPGRADE_SKILL_DIR/scripts" "$INSTALL_SKILL/scripts"
cp -R "$TEST_DIR/../fixtures" "$INSTALL_SKILL/tests/fixtures"
cp "$TEST_DIR/../test-lib.sh" "$TEST_DIR/../run.sh" "$INSTALL_SKILL/tests/"
cp "$TEST_DIR/01_apply_scaffold_rewrites_agent_paths.sh" "$TEST_DIR/04_file_mode_directory_union_includes_meta_only.sh" "$INSTALL_SKILL/tests/cases/"

# 子套件必须测试复制出来的入口，不能继承外层 override 绕回源码。
if ! (unset DOCS_UPGRADE_TEST_SCRIPT; "$BASH" "$INSTALL_SKILL/tests/run.sh") >"$TMP_DIR/output" 2>&1; then
  cat "$TMP_DIR/output"
  fail '临时安装布局测试失败'
fi
assert_contains '总计: 2, 通过: 2, 失败: 0' "$TMP_DIR/output"
pass '临时 .agents 安装布局：脚本、模块、fixture 与测试入口均可运行'
