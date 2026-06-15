---
name: sdx-analysis
description: >-
  在已共识 `SOLUTION-{IDEA-ID}.md` 上细化 FR/MVP/依赖/风险，产出 `ANALYSIS-{IDEA-ID}.md`（六章）与会话 spec。用于 `/sdx-analysis`，或口述「拆 MVP」「需求分析」「细化方案」且上下文已有/可对齐上游方案时。
  总确认前禁写 `{DOC_DIR}/analysis/ANALYSIS-*.md`（例外见 references/gates.md）。
  仅有会议纪要无 SOLUTION、或只要 SOLUTION/PRD/ASD/DSD、或仅以 docs-distill / docs-extract / docs-indexing 交付时，分流对应技能。
---

# sdx-analysis

顺序：**是否本技能 → 读 references → 会话 spec → 门禁 → 校验**。

读者：需求分析师撰写；产品/架构评审。实现设计走 `sdx-architect`、`sdx-design`。

**公司库**（`KNOWLEDGE_TYPE=company`）：见 [references/workflow.md](references/workflow.md)「公司库」段；产出 `company/analysis/ANALYSIS-*.md`，PRD 由各 `system/` 侧 `/sdx-prd` 承接。

---

## 边界

| 负责 | 不负责 |
|------|--------|
| `ANALYSIS-*.md`、会话 spec、基于 **SOLUTION-{IDEA-ID}.md** 的细化、门禁与校验 | `SOLUTION-*` 初稿；`PRD-*`/`ASD-*`/`DSD-*` 正式稿；以 docs-distill / docs-extract / docs-indexing / docs-archive 为主路径 |

无方案输入 → 引导 `sdx-solution`。用户锁定其他产物时转对应技能。

---

## 最少输入

- 可对齐的 **`SOLUTION-{IDEA-ID}.md`**（或用户认可的缺口策略）。
- IDEA-ID 与上游一致；门禁粒度（6G / 精简 4G）；深度。
- `{DOC_DIR}/analysis/`、`{DOC_DIR}/superpowers/specs/` 可写路径。

---

## 路由表


| 目的 | 文件 |
|------|------|
| 会话 spec 路径 | [session-spec-path.md](../../references/session-spec-path.md) |
| 门禁与例外 | `references/gates.md` |
| 流程与阶段 | `references/workflow.md` |
| brainstorming 嵌入 | `references/brainstorming-integration.md` |
| IDEA-ID、编号、`--depth` | `references/core-concepts.md` |
| 原则与异常处理 | `references/design-principles.md` |
| 概念反模式 | `references/anti-patterns.md` |
| 操作易错 | `gotchas.md` |
| 受众与语言 | `references/audience-and-language.md` |
| 终检 | `references/quality-checklist.md` |
| 模板 | 阶段二 `assets/analysis-session-spec-template.md`；阶段三 `assets/analysis-template.md`；形态参考 `assets/samples/mini-analysis-example.md` |

---

## 门禁

总确认前禁止写入 `{DOC_DIR}/analysis/ANALYSIS-*.md`。`PENDING` / `CONFIRMED` 见 `references/gates.md`。

---

## 产出与校验

- 会话 spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-sdx-analysis.md`
- 正式稿：`{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md`

```bash
agent/skills/sdx-analysis/scripts/validate-analysis.sh
agent/skills/sdx-analysis/scripts/validate-analysis.sh --file path/to/ANALYSIS-xxx.md --gate-check
```

---

## 评测

样本：`evals/evals.json`；元数据：`evals/eval-metadata-template.json`；评分：`agents/grader.md`；归因：`agents/analyzer.md`。

---

## 钩子

`python3 agent/hooks/sdx_gate_common.py --gate analysis`（注册见 `agent/hooks.json`，须启用 Hooks）。