---
type: Documentation
title: analysis — 需求分析文档
---
# analysis — 需求分析文档

SDD **需求分析**阶段目录：产出 `ANALYSIS-{IDEA-ID}.md`，作为 [../requirements](../requirements) 输入；上游 [../solutions](../solutions) 中 `SOLUTION-{IDEA-ID}.md`。

## 交付物

| 项 | 约定 |
|----|------|
| 文件 | 根目录平铺 `ANALYSIS-{IDEA-ID}.md` |
| IDEA-ID | 与 `SOLUTION-{IDEA-ID}.md`、`REQUIREMENT-{IDEA-ID}/` **同链**（见 [../../agent/knowledge/naming-conventions.md](../../agent/knowledge/naming-conventions.md)） |
| 文档元数据 | 文末 `## 文档元数据`：`id` 与文件名一致；`parent` → 对应 `SOLUTION-{IDEA-ID}`（**勿**在文首使用 `---` YAML frontmatter） |

## 输入

- [../solutions/](../solutions/) — `SOLUTION-{IDEA-ID}.md`
- [../knowledge/](../knowledge/) — 五视角实体登记、实现映射与[治理基线](../../agent/knowledge/knowledge-governance.md)
- 规约：各需求包内 `specs/`

细化结论可与 **business、product** 等系统层实体 ID 追溯；实现方案宜与 **application、data** 的应用层登记与物理落地对齐。

## 分析索引表

| 文档文件名 | 标题 | 关联解决方案 | 简要说明 |
|------------|------|--------------|----------|
| ... | ... | ... | ... |

## 规范

- 工作流：[../../agent/skills/sdx-analysis/SKILL.md](../../agent/skills/sdx-analysis/SKILL.md)
- 模板：[../../agent/skills/sdx-analysis/assets/analysis-template.md](../../agent/skills/sdx-analysis/assets/analysis-template.md)

## 索引维护

每新增或评审一份 `ANALYSIS-{IDEA-ID}.md`，须同步更新上表；重大结构变更时按需更新根 `INDEX_GUIDE.md`。
