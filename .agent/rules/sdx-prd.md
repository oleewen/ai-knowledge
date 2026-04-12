---
description: sdx-prd 闸门与 PRD 文档产出路径
globs: application/requirements/**/*
alwaysApply: false
---

# sdx-prd（产品需求阶段）

编辑或新建 `application/requirements/**/PRD-*.md` 时：

1. **须先**完成中间会话 spec（路径约定见 [.agent/skills/sdx-prd/SKILL.md](../skills/sdx-prd/SKILL.md)）：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-prd.md`，并完成闸门 **用户总确认**。
2. 在会话 spec 文末使用标记：`<!-- sdx-prd-gate: CONFIRMED -->`（总确认前为 `PENDING`），且文中须出现目标 `PRD-*.md` 文件名，供钩子与校验脚本识别。
3. 例外：用户在同一对话中**明示**跳过闸门或授权直写终稿时，可遵循用户指令；或在环境中设置 `SDX_PRD_ALLOW_PRD_WRITE=1`（仅限人工知情场景）。

完整流程、HARD-GATE 与校验命令见 [.agent/skills/sdx-prd/SKILL.md](../skills/sdx-prd/SKILL.md)。
