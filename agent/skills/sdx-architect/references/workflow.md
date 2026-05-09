# sdx-architect 工作流

门禁与例外：[gates.md](gates.md)。

## 目标

`ASD-{IDEA-ID}-{N}.md` 可追溯、可作 `/sdx-design` 输入。

## 流程

1. **准备**：`IDEA-ID`、`MVP-Phase`、`KNOWLEDGE_TYPE`；`PRD`、`ANALYSIS` 与约束。
2. **草稿**：§1–§3 提纲；分歧列方案再收敛。
3. **用户总确认**：同意前不写正式 `{DOC_DIR}/requirements/**/ASD-*.md`。
4. **落盘**：命名与路径见 [SKILL.md](../SKILL.md)；`asd-template.md` + 文末 YAML。
5. **校验**：`agent/skills/sdx-architect/scripts/validate-asd.sh`，失败修正后重跑。

## 原则

门禁先于速度；先骨架后细节；ASD 不含 DSD 级实现。
