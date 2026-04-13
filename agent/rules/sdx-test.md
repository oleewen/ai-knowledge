---
description: sdx-test 闸门与 TDD 文档产出路径
globs: application/requirements/**/*
alwaysApply: false
---

# sdx-test（测试设计阶段）

编辑或新建 `application/requirements/**/TDD-*.md` 时：

1. **须先**完成中间会话 spec（路径约定见 [agent/skills/sdx-test/SKILL.md](../skills/sdx-test/SKILL.md)）：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-test.md`，并完成闸门 **用户总确认**。
2. 在会话 spec 文末使用标记：`<!-- sdx-test-gate: CONFIRMED -->`（总确认前为 `PENDING`），且文中须出现目标 `TDD-*.md` 文件名，供钩子与校验脚本识别。
3. 例外：用户在同一对话中**明示**跳过闸门或授权直写终稿时，可遵循用户指令；或在环境中设置 `SDX_TEST_ALLOW_TDD_WRITE=1`（仅限人工知情场景）。

完整流程、HARD-GATE 与校验命令见 [agent/skills/sdx-test/SKILL.md](../skills/sdx-test/SKILL.md)。
