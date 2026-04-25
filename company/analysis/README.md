# analysis — 需求分析文档

本目录用于记录**需求分析文档**，对应 AI SDD 需求分析阶段产出。基于解决方案文档与知识库进行深度研究、需求细化、MVP 拆分与依赖/风险评估，输出以 `ANALYSIS-{IDEA-ID}.md` 命名的文档。

## 定位与用途

- **输入**：解决方案文档（[../solutions](../solutions)）、知识库（[../architecture](../architecture)）、规约（各需求包内 `specs/` 或 [../specs/README.md](../specs/README.md) 说明）。
- **输出**：需求分析文档 `ANALYSIS-{IDEA-ID}.md`，作为后续需求交付（PRD/ADD/TDD）的输入。

## 分析索引表

| 文档文件名              | 标题                | 关联解决方案 | 简要说明       |
|------------------------|---------------------|--------------|----------------|
| ...                    | ...                 | ...          | ...            |

> 📚 注：每新增/评审一份 `ANALYSIS-{IDEA-ID}.md`，请同步补充本表格，便于快速检索与项目追溯。


## 命名与ID

- **文件名**：`ANALYSIS-{IDEA-ID}.md`，其中 **IDEA-ID** 须与上游 `SOLUTION-{IDEA-ID}.md` 及下游 `REQUIREMENT-{IDEA-ID}/` 同链一致（见 [../constitution/standards/naming-conventions.md](../constitution/standards/naming-conventions.md)）。
- **文档内**：文末「## 文档元数据」中 `id` 与文件名一致，`parent` 指向对应的 `SOLUTION-{IDEA-ID}`（勿在文件开头使用 `---` YAML frontmatter）。

## 规范与模板

- **阶段目标与工作流**：见 [../../agent/skills/sdx-analysis/SKILL.md](../../agent/skills/sdx-analysis/SKILL.md)（三阶段：参数确认 → 逐门禁草稿与会话 spec → 分块定稿与终检）。
- **文档模板**：见 [../../agent/skills/sdx-analysis/assets/analysis-template.md](../../agent/skills/sdx-analysis/assets/analysis-template.md)。

## 集成关系

- 需求分析文档的 `parent` 指向 [../solutions](../solutions) 下的解决方案。
