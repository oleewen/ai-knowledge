---
description: docs-archive 闸门与归档写入路径
globs: system/architecture/**/*
alwaysApply: false
---

# docs-archive（应用知识归档到系统库）

对 `system/architecture/` 受管区块及归档相关日志执行**写入**或等价工具调用前：

1. **须先**完成中间会话 spec（路径约定见 [.agent/skills/docs-archive/SKILL.md](../skills/docs-archive/SKILL.md)）：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-archive.md`，并完成闸门 **用户总确认**（详见 [.agent/skills/docs-archive/reference/interaction-gate.md](../skills/docs-archive/reference/interaction-gate.md)）。
2. 在会话 spec 文末使用标记：`<!-- docs-archive-gate: CONFIRMED -->`（总确认前为 `PENDING`），且文中须写明目标应用、`--full` / `--since` / `--dry-run` 等关键参数摘要。
3. 例外：用户在同一对话中**明示**跳过闸门或授权直写时，可遵循用户指令；或在环境中设置 `DOCS_ARCHIVE_ALLOW_WRITE=1`（仅限人工知情场景）。

涉及 `system/changelogs/CHANGE-LOG.md` 与 `system/application-*/changelogs/ARCHIVE-LOG.md` 的追加与锚点更新，与上述闸门**同一原子事务**，适用同一交互与确认要求。

完整流程、HARD-GATE 与场景表见 [.agent/skills/docs-archive/reference/interaction-gate.md](../skills/docs-archive/reference/interaction-gate.md) 与 [.agent/skills/docs-archive/SKILL.md](../skills/docs-archive/SKILL.md)。
