# analysis — 需求分析文档

本目录用于记录**需求分析文档**，对应 AI SDD 需求分析阶段产出。基于解决方案文档与知识库进行深度研究、需求细化、MVP 拆分与依赖/风险评估，输出以 `ANALYSIS-{IDEA-ID}.md` 命名的文档。

## 定位与用途

- **输入**：解决方案文档（[../solutions](../solutions)）、知识库（[../knowledge](../knowledge)）、规约（各需求包内 `specs/` 或 [../specs/README.md](../specs/README.md) 说明）。
- **输出**：需求分析文档 `ANALYSIS-{IDEA-ID}.md`，作为后续需求交付（PRD/ADD/TDD）的输入。

## 分析索引表

| 文档文件名              | 标题                | 关联解决方案 | 简要说明       |
|------------------------|---------------------|--------------|----------------|
| ...                    | ...                 | ...          | ...            |

> 📚 注：每新增/评审一份 `ANALYSIS-{IDEA-ID}.md`，请同步补充本表格，便于快速检索与项目追溯。


## 命名与ID

- **文件名**：`ANALYSIS-{IDEA-ID}.md`，其中 **IDEA-ID** 须与上游 `SOLUTION-{IDEA-ID}.md` 及下游 `REQUIREMENT-{IDEA-ID}/` 同链一致（见 [../knowledge/constitution/standards/naming-conventions.md](../knowledge/constitution/standards/naming-conventions.md)）。
- **文档内**：文末「## 文档元数据」中 `id` 与文件名一致，`parent` 指向对应的 `SOLUTION-{IDEA-ID}`（勿在文件开头使用 `---` YAML frontmatter）。

## 规范与模板

- **阶段目标与工作流**：见 [../../.ai/skills/sdx-analysis/SKILL.md](../../.ai/skills/sdx-analysis/SKILL.md)（深度研究 → 需求细化 → MVP 拆分与规划 → 依赖分析与风险评估 → 文档输出与评审）。
- **文档模板**：见 [../../.ai/skills/sdx-analysis/assets/analysis-template.md](../../.ai/skills/sdx-analysis/assets/analysis-template.md)。

## 集成关系

- 需求分析文档的 `parent` 指向 [../solutions](../solutions) 下的解决方案。
- 细化需求、MVP 范围可与 **business、product** 等功能/用例 ID 建立追溯；实现方案与 **technical、data** 对齐。
