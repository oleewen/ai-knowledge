---
name: sdx-solution
description: >-
  产出共识级 `SOLUTION-{IDEA-ID}.md`（七章）与会话 spec。用于 `/sdx-solution`，或需求模糊/有冲突、需结构化与 MVP；口述「写方案」「整理业务目标」亦触发。
  总确认前禁写 `{DOC_DIR}/solutions/SOLUTION-*.md`（例外见 references/gates.md）。
  用户只要 ANALYSIS/PRD/ASD/DSD 或仅以 docs-distill / docs-extract / docs-indexing 交付时，分流对应技能。
---

# sdx-solution

顺序：**路由 → 读 references → 会话 spec → 门禁 → 校验**。

读者：解决方案撰写方；评审为产品/架构。实现详设走 `sdx-architect`、`sdx-design`。

---

## 边界

| 负责 | 不负责 |
|------|--------|
| `SOLUTION-*.md`、会话 spec、`…-sdx-solution.md`、一至三阶段、影响面/冲突/MVP 共识（业务表述） | `ANALYSIS-*`/`PRD-*`/`ASD-*`/`DSD-*`/`TDD-*` 正式稿；实现级 specs；`requirements/` 规约；以 `docs-distill` / `docs-extract` / `docs-indexing` / `docs-archive` 为主路径 |

用户已锁定下游产物时转对应 `sdx-*` 或 `docs-*`。

---

## 最少输入

- 至少一种原始业务描述（过短则先补）。
- IDEA-ID、门禁粒度（7G/精简 5G）、深度（可与用户确认）。
- 知晓 `{DOC_DIR}`、`docs/superpowers/specs/` 可写路径。

---

## 路由表

| 目的 | 文件 |
|------|------|
| 门禁与例外 | `references/gates.md` |
| 流程与阶段 | `references/workflow.md` |
| 多方案与 brainstorming | `references/brainstorming-integration.md` |
| IDEA-ID、编号、`--depth` | `references/core-concepts.md` |
| 原则与错误处理 | `references/design-principles.md` |
| 概念层反模式 | `references/anti-patterns.md` |
| 操作层易错 | `gotchas.md` |
| 受众与语言 | `references/audience-and-language.md` |
| 终检 | `references/quality-checklist.md` |
| 模板 | 阶段二 `assets/solution-session-spec-template.md`；阶段三 `assets/solution-template.md` |

---

## 门禁

总确认前禁止写入 `{DOC_DIR}/solutions/SOLUTION-*.md`。`PENDING` / `CONFIRMED` 与例外见 `references/gates.md`。

---

## 产出与校验

- 会话 spec：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-solution.md`
- 正式稿：`{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`

```bash
agent/skills/sdx-solution/scripts/validate-solution.sh
agent/skills/sdx-solution/scripts/validate-solution.sh --file path/to/SOLUTION-xxx.md --gate-check
```

---

## 评测

样本与断言：`evals/evals.json`；元数据：`evals/eval-metadata-template.json`；评分：`agents/grader.md`；归因：`agents/analyzer.md`。

---

## 钩子

`python3 agent/hooks/sdx_gate_common.py --gate solution`（注册见 `agent/hooks.json`，需启用 Hooks）。
