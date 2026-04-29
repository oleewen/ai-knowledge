#!/usr/bin/env bash
# 历史入口：单文档 ADD 校验已拆分为 ASD + DSD。本脚本转发至 validate-dsd.sh。
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/validate-dsd.sh" "$@"
