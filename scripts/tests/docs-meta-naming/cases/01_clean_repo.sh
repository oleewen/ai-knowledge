#!/usr/bin/env bash
# 01_clean_repo.sh — 已退役（2026-06-26 调整后）
#
# 原职责：调用 scripts/check-docs-meta-naming.sh 验证 `docs_meta.md → docs-meta.md`
# 命名迁移彻底完成。脚本已于本次调整后被删除；套件与本 case 保留作历史占位，
# scripts/tests/run.sh 中 `docs-meta-naming` 注册项也保留。
#
# 行为：skip（exit 0），不执行任何检查。

set -euo pipefail

echo "01_clean_repo: SKIPPED (scripts/check-docs-meta-naming.sh 已于 2026-06-26 退役；套件保留作占位)"
