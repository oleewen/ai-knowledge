#!/usr/bin/env bash
# 兼容入口：转发至 .ai/skills 内副本（单一事实来源，方案丙）
_BOOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$_BOOT/../.ai/scripts/sdx-doc-root.sh"
