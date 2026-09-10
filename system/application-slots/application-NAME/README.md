---
type: Documentation
tags: [federation]
title: "application-{NAME} 槽位（模板）"
---
<!-- markdownlint-disable-next-line MD025 -->
# application-NAME 槽位（模板）

`application-slots/` 下挂载应用库镜像。落地时将 `application-{NAME}` / `application-NAME` 换为实际 `app_name`。经 [`/docs-pull`](../../../agent/skills/docs-pull/SKILL.md) 从应用库本地 `path` 同步至此。

中央应用主库：[../../../application/README.md](../../../application/README.md) · 契约：[../../DESIGN.md](../../DESIGN.md) §3
