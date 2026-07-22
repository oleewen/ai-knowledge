---
type: Documentation
title: analysis — 需求分析文档
---
# analysis — 需求分析文档

公司层 SDD 分析目录：`ANALYSIS-{IDEA-ID}.md`。

- 上游：[../solutions/](../solutions/README.md) `SOLUTION-{IDEA-ID}.md`
- 下游：各系统 [`system/requirements/`](../../system/requirements/README.md) 承接 PRD/ASD/DSD/TDD（`company/` 无 `requirements/`）
- 企业架构：[../knowledge/](../knowledge/README.md)

## 交付物

| 项 | 约定 |
|----|------|
| 文件 | 根目录平铺 `ANALYSIS-{IDEA-ID}.md` |
| IDEA-ID | 与 SOLUTION / 各系统 REQUIREMENT **同链** |
| frontmatter | `id` 与文件名一致；`parent` → 对应 SOLUTION |

## 索引

| 文档 | 标题 | 关联方案 | 说明 |
|------|------|----------|------|
| ANALYSIS-EXAMPLE.md | 示例跨系统需求分析 | SOLUTION-EXAMPLE | 最小演示链 |

规范：[sdx-analysis](../../agent/skills/sdx-analysis/SKILL.md) · 模板见该技能 `assets/`。
