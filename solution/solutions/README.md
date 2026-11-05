---
type: Documentation
title: solutions（解决方案）文档
---
# solutions（解决方案）

本层唯一 SDD 方案目录：平铺 `SOLUTION-{IDEA-ID}.md`。**仅** `/sdx-solution`（`KNOWLEDGE_TYPE=solution`）。每版是完整的七章解决方案分析，§1.3 说明相对前驱的变化。`parent` 保持线性链；无后继者为现行候选，有多个候选时由用户选择。

无 `analysis/` / `features/` / `requirements/`。

| 编号 | 标题 | 状态 |
|------|------|------|
| [SOLUTION-EXAMPLE](SOLUTION-EXAMPLE.md) | 示例解决方案 | draft |

旧六段稿续写前先确认内容映射再升级；校验器只读识别并提示迁移。下游系统分析按需引用，已有方案时核对其约束。

规范：[sdx-solution](../../agent/skills/sdx-solution/SKILL.md)。superseded 方案追溯用 git。

目录与阅读顺序见 [index.md](index.md)。
