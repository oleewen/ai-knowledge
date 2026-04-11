#!/usr/bin/env bash
# 开发时转加载仓库 SSOT：根目录 scripts/docs-config.sh。
# docs-init 安装到 $AGENT_HOME/scripts/ 时会用完整 scripts/docs-config.sh 覆盖本文件。

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_SCRIPT_DIR}/../../scripts/docs-config.sh"
