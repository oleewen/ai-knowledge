# sdx-architect 工作流

门禁与例外见 [gates.md](gates.md)。

## 目标

产出可追溯、可落地的 `ASD-{IDEA-ID}-{N}.md`，为 `/sdx-design` 提供稳定输入。

## 流程

1. **准备**：确认 `IDEA-ID`、`MVP-Phase`、`KNOWLEDGE_TYPE`；输入 `ANALYSIS`、`PRD` 与约束。
2. **会话草稿**：提纲对应 §1–§3，分歧列方案并收敛。
3. **用户总确认**：未同意以当前草稿生成 ASD 正文前，不写入正式 `{DOC_DIR}/requirements/**/ASD-*.md`。
4. **落盘**：路径与命名见 [SKILL.md](../SKILL.md)；正文遵循 `assets/asd-template.md`，含文末 YAML 元数据。
5. **校验**：仓库根 `agent/skills/sdx-architect/scripts/validate-asd.sh`；失败则修正后重跑。

## 原则

门禁优先于速度；先骨架后细节；ASD 仅架构层，不下沉 DSD 实现细节。
