---
type: Change Log
title: CHANGE-LOG（联邦槽位同步）
---
<!-- markdownlint-disable-next-line MD025 -->
# CHANGE-LOG（联邦槽位同步）

`system-slots/` 层内共用同步留痕。由 `/docs-pull` 追加；条目含 `sys_name` / `source` / `commit` / `action`。

## 写入约定

- 新记录按时间倒序追加
- `action`：`pull` / `clone` / `link-fix` / `migrate`（可组合）
- 槽位本体为软链：`system-{NAME}` → 下级系统库 `DOC_ROOT`
