---
type: Documentation
title: solutions — 解决方案文档
---
# solutions — 解决方案文档

索引入口见 [index.md](index.md)。

SDD **解决方案**阶段目录：产出 `SOLUTION-{IDEA-ID}.md`，作为 [../analysis](../analysis) 输入。

## 交付物

| 项 | 约定 |
|----|------|
| 文件 | 根目录平铺 `SOLUTION-{IDEA-ID}.md`（本目录无 `{dirname}_meta.yaml`） |
| 归档 | 已完结或 superseded 方案移入 [archive/](archive/) |
| IDEA-ID | 需求链统一标识（见 [../../agent/knowledge/naming-conventions.md](../../agent/knowledge/naming-conventions.md)） |
| 文档元数据 | 文首 YAML frontmatter：`id` 与文件名一致；可选 `parent`、`dependencies`、`tags` |

## 输入

- 外部 — 业务诉求（邮件、会议纪要、工单等）
- [../knowledge/](../knowledge/README.md) — 企业架构五视角文档
- 规约：各需求包内 `specs/`

## 方案索引表

| 解决方案编号 | 标题 | 关联 analysis | 状态 | 更新时间 |
|--------------|------|---------------|------|----------|
| SOLUTION-EXAMPLE | 示例跨系统解决方案 | ANALYSIS-EXAMPLE | draft | 2026-06-21 |

## 规范

- 工作流：[../../agent/skills/sdx-solution/SKILL.md](../../agent/skills/sdx-solution/SKILL.md)
- 模板：[../../agent/skills/sdx-solution/assets/solution-template.md](../../agent/skills/sdx-solution/assets/solution-template.md)

## 索引维护

每新增或评审一份 `SOLUTION-{IDEA-ID}.md`，须同步更新上表；重大结构变更时按需更新根 `index.md`。
