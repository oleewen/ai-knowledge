---
name: knowledge-build
description: >
  全库知识构建编排（概念技能）：组合 document-indexing、agent-guide、knowledge-extract 等与中央库治理相关的步骤。
  本仓库若未单独展开多阶段脚本，请以各子 Skill 的 SKILL.md 为准分步执行。
---

# knowledge-build（编排说明）

本条目用于 **导航与链接稳定**：具体步骤以以下 Skill 为准，按需顺序执行。

| 步骤 | Skill | 说明 |
|------|--------|------|
| 文档索引 | [.ai/skills/document-indexing/SKILL.md](../document-indexing/SKILL.md) | 产出根目录 `INDEX_GUIDE.md`（或 `docs/INDEX_GUIDE.md`）与 `system/changelogs/indexing-log.jsonl` 等 |
| Agent 入口 | [.ai/skills/agent-guide/SKILL.md](../agent-guide/SKILL.md) | 产出根目录 `README.md`、`AGENTS.md`（须已有落盘 Index） |
| 四视角提取（可选） | [.ai/skills/knowledge-extract/SKILL.md](../knowledge-extract/SKILL.md) | 产出各视角 `*_knowledge.json` 等 |

变更基线见 [.ai/skills/document-change/SKILL.md](../document-change/SKILL.md) 与 `system/changelogs/changes-index.*`。
