---
type: Change Log
title: CHANGE-LOG
---
<!-- markdownlint-disable-next-line MD025 -->
# CHANGE-LOG

`company/` 目录级变更留痕。

## 写入约定

- 新记录按时间倒序追加
- 仅记 `company/` 目录级变更与汇总事件
- 索引运行详情 → `INDEXING-LOG.md`

<!-- change_time=2026-09-10 16:00:00 -->
## 2026-09-10 — 联邦系统槽位迁入 system-slots

- 新增 `system-slots/`（README + index + docs-meta 一级）
- 模板 `system-SYSNAME/` → `system-slots/system-NAME/`；路径契约 `system-slots/system-{NAME}/`
- 旧根路径 `company/system-*` 硬切；CLI 仍 `--sys-name`
- 系统层 `application-slots` 对称延后见根 `changelogs/GRILL-LOG.md`
- `viz.html` 仍含旧路径快照，需在 company 上下文跑 `/docs-okf` 刷新

<!-- change_time=2026-04-26 00:00:00 -->
