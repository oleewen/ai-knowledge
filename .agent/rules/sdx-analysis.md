---
description: sdx-analysis 闸门与 ANALYSIS 文档产出路径
globs: application/analysis/**/*
alwaysApply: false
---

# sdx-analysis（需求分析阶段）

编辑或新建 `application/analysis/ANALYSIS-*.md` 时：

1. **须先**完成中间会话 spec（路径约定见 [.agent/skills/sdx-analysis/SKILL.md](../skills/sdx-analysis/SKILL.md)）：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-analysis.md`，并完成闸门 **用户总确认**。
2. 在会话 spec 文末使用标记：`<!-- sdx-analysis-gate: CONFIRMED -->`（总确认前为 `PENDING`），且文中须出现目标 `ANALYSIS-*.md` 文件名，供钩子与校验脚本识别。
3. 例外：用户在同一对话中**明示**跳过闸门或授权直写终稿时，可遵循用户指令；或在环境中设置 `SDX_ANALYSIS_ALLOW_ANALYSIS_WRITE=1`（仅限人工知情场景）。

完整流程、HARD-GATE 与校验命令见 [.agent/skills/sdx-analysis/SKILL.md](../skills/sdx-analysis/SKILL.md)。
