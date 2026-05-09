---
name: docs-extract
description: >
  按段落关键词相关度从 `--sources` 提炼业务知识，写入 `--overview` 第三列（A/U/D）；支持 `--dry-run`。不写 `DISTILL-LOG`；第三列不写来源脚注。
  `/docs-extract`、任意源 → overview、或说「提炼进 overview」「抽取业务知识到系统库」「从设计文档整理进知识库」等时触发。
  用户明确要求仅 docs-distill、docs-archive、docs-indexing、SDD 终稿为主路径时分流。
---

# docs-extract：任意源 → overview 第三列

调度器：判定归本技能后，按 `references/` 与会话 spec、门禁执行；段落级筛选后更新第三列。

## 边界

| 负责 | 不负责 |
|------|--------|
| 任意源 → overview 第三列；段落筛选；`docs-extract-gate` + `--dry-run`；A/U/D | docs-distill 上行主路径；docs-archive；docs-indexing；代写 SDD 终稿 |

明确只要上述下游 → 转对应 `docs-*` / `sdx-*`。

## 前置

- `--sources`、`--overview` 可解析；overview 含 `## 文档关键词`（缺则补，见 gotchas）。
- 会话 spec：`docs/superpowers/specs/`；目标常位于 `system/architecture/overview/`。

## 执行顺序（先读后写）

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. [interaction-gate.md](references/interaction-gate.md)
4. [core-concepts.md](references/core-concepts.md)（术语混淆时）
5. [extract-spec.md](references/extract-spec.md)（阶段 1、4）
6. [design-principles.md](references/design-principles.md)
7. [anti-patterns.md](references/anti-patterns.md)
8. [quality-checklist.md](references/quality-checklist.md)
9. [gotchas.md](gotchas.md)
10. [brainstorming-integration.md](references/brainstorming-integration.md)（长澄清）
11. [assets/docs-extract-session-spec-template.md](assets/docs-extract-session-spec-template.md)（新 spec）

## 门禁

阶段 3 未 `CONFIRMED`（且无合法例外）→ **禁止**阶段 4。细则见 [gates.md](references/gates.md)、[agent/rules/CONVENTIONS.md](../../rules/CONVENTIONS.md#artifact-gates)。

## 产出

- 会话 spec：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-extract.md`（可选用 assets 模板）
- 正式：`--overview` 对应 `*.md` 第三列更新

## 评测

- [evals/evals.json](evals/evals.json)
- [evals/eval-metadata-template.json](evals/eval-metadata-template.json)
- [agents/grader.md](agents/grader.md)
- [agents/analyzer.md](agents/analyzer.md)

## 钩子

`python3 agent/hooks/sdx_gate_common.py --gate extract`（见 `agent/hooks.json`）；与会话 spec `<!-- docs-extract-gate: CONFIRMED -->` 及目标 overview basename 对齐。详见 [references/gates.md](references/gates.md)、[agent/hooks/README.md](../../hooks/README.md)。

## 索引

全目录与打开时机：[references/README.md](references/README.md)。
