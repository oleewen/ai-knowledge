---
name: sdx-architect
description: >
  基于 PRD 产出 ASD §1–§3；可选 spec-asd-*.md。KNOWLEDGE_TYPE=system|company 时为联邦概要。
  触发：ASD、边界、变更、§3 规约摘要或 spec-asd-*。
  分流：API/DDL/DSD → sdx-design；docs-* 或仅其他 SDX 阶段 → 对应技能。
  门禁：总确认前禁写 {DOC_DIR}/requirements/**/ASD-*.md（例外见 gates.md）。
compatibility: Bash 5+；config-bootstrap 解析 DOC_ROOT；validate-asd.sh。
---

# sdx-architect（架构设计）

判主路径 → 读 references/ → 总确认 → ASD 终稿。**DSD 正文 → sdx-design**。

## 边界

| 负责 | 不负责 |
|------|--------|
| ASD-*.md、可选 spec-asd-*.md、服务边界与 §3 摘要 | DSD 实现级 API/DDL；docs-* 主路径 |

## 路由

| 目的 | 文件 |
|------|------|
| 会话 spec 路径 | [session-spec-path.md](../../references/session-spec-path.md) |
| 门禁 / 流程 | [gates.md](references/gates.md)、[workflow.md](references/workflow.md) |
| brainstorming | [brainstorming-integration.md](references/brainstorming-integration.md) |
| KNOWLEDGE_TYPE（SSOT） | [knowledge-type-modes.md](references/knowledge-type-modes.md) |
| 反模式 / 终检 | [anti-patterns.md](references/anti-patterns.md)、[quality-checklist.md](references/quality-checklist.md) |
| 模板 | [asd-template.md](assets/asd-template.md)、[asd-spec-template.md](assets/asd-spec-template.md) |

## 最少输入

- **PRD**（必需）；**ANALYSIS**、**KNOWLEDGE_TYPE**（建议）。缺项先澄清，不落正式 ASD。

## 门禁

总确认前禁止 `{DOC_DIR}/requirements/**/ASD-*.md`（[gates.md](references/gates.md)）。

## 产出与校验

- Spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-sdx-architect.md`
- ASD：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-architect/scripts/validate-asd.sh
agent/skills/sdx-architect/scripts/validate-asd.sh --file path/to/ASD-xxx.md --gate-check
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate architect`。
