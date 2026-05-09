---
name: sdx-prd
description: >
  将 ANALYSIS 中当前 MVP 细化为可评审、可验收的 PRD（十一章，`assets/prd-template.md`）：用户故事、用例、流程、验收等。
  触发：/sdx-prd；或用户要「写 PRD」「细化用户故事/业务流程」「需求分析转 PRD」，且可指向上游 ANALYSIS。
  分流：仅有会议纪要、无 SOLUTION/ANALYSIS；或只要 sdx-solution/analysis/architect/design；或主路径为 docs-distill/extract/indexing → 对应技能，非本技能主责。
  门禁：未完成「草稿用户总确认」不得写 `{DOC_DIR}/requirements/**/PRD-*.md`（例外见 references/gates.md）。
compatibility: Bash 5+；`scripts/config-bootstrap.sh` 解析 `DOC_ROOT`；钩子 `python3 agent/hooks/sdx_gate_common.py --gate prd`（见 `agent/hooks.json`）。
---

# 产品需求（sdx-prd）

先判主责 → 读 `references/` → 会话 **`...-sdx-prd.md`** → 门禁收口 → **`PRD-{IDEA-ID}-{N}.md`**（十一章）。

读者：**产品**（主笔与验收）；**分析、架构、研发**参评可行性与范围。下游：**sdx-architect（ASD）**、**sdx-design（DSD）**。

---

## 路由

| 主路径 | 技能 |
|--------|------|
| docs-distill / extract / archive / indexing 为主 | **docs-*** |
| SOLUTION / ANALYSIS / ASD / DSD 为主、不要 PRD | 对应 **sdx-*** |
| **PRD**、会话 spec、G1–G11（或精简 6G）、Qclose、validate-prd | **本技能** |

**负责**：`PRD-*.md`、会话 spec、当前 **MVP-Phase-{N}** 内流程/用例/故事/规则/验收、门禁。  
**不负责**：`SOLUTION-*` / `ANALYSIS-*` 初稿、`ASD-*`/`DSD-*` 正式稿、docs-* 主线。

---

## 前置

- **`ANALYSIS-{IDEA-ID}.md`** 含目标 MVP（缺则先 `sdx-analysis`）。  
- **IDEA-ID**、**`N`** 与终稿路径一致。  
- 知悉 `{DOC_DIR}/requirements/.../MVP-Phase-{N}/` 与 `docs/superpowers/specs/`。  
用户要先方案/分析时，不强行套全流程。

---

## 执行路由（先读后写）

1. [gates.md](references/gates.md)  
2. [workflow.md](references/workflow.md)  
3. [brainstorming-integration.md](references/brainstorming-integration.md)  
4. 口径不明 → [core-concepts.md](references/core-concepts.md)  
5. 原则/编号 → [design-principles.md](references/design-principles.md)  
6. 叙事反模式 → [anti-patterns.md](references/anti-patterns.md)  
7. 操作易错 → [gotchas.md](gotchas.md)  
8. 语气 → [audience-and-language.md](references/audience-and-language.md)  
9. 终检 → [quality-checklist.md](references/quality-checklist.md)  
10. 模板：`assets/prd-session-spec-template.md`、`assets/prd-template.md`；形态参考 `assets/samples/mini-prd-example.md`

---

## 门禁

总确认前禁止 **`{DOC_DIR}/requirements/**/PRD-*.md`**；`PENDING`/`CONFIRMED` 与例外见 [gates.md](references/gates.md)。

---

## 产出与校验

- **会话 spec**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-prd.md`  
- **PRD**：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`

仓库根：

```bash
agent/skills/sdx-prd/scripts/validate-prd.sh
agent/skills/sdx-prd/scripts/validate-prd.sh --file path/to/PRD-xxx.md --gate-check
```

---

## 评测与工程化

`evals/evals.json`、`evals/eval-metadata-template.json`、`agents/grader.md`、`agents/analyzer.md`。Hooks 须在仓库启用后方拦截写入。
