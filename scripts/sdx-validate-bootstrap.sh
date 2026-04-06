#!/usr/bin/env bash
# 兼容入口：转发至 .ai/skills 内副本（单一事实来源）
_BOOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$_BOOT/../.ai/scripts/sdx-validate-bootstrap.sh"
