---
name: docs-indexing
description: >
  生成九章索引指南（如仓库根 index.md 或各 DOC_DIR 下 index.md），维护各 DOC_DIR 下 changelogs/INDEXING-LOG.md 主表（最新在上）。
  触发：/docs-indexing、建/更索引、文档地图、Onboarding、口述「整理 INDEX」。
  分流：用户只要 docs-build/distill/extract/SDD 为主路径 → 对应技能，勿单跑本技能。
  门禁：未完成 spec 与用户总确认（docs-indexing-gate: CONFIRMED）前禁止写索引指南（index.md / index.md）与 */changelogs/INDEXING-LOG.md。
---

# docs-indexing（文档索引）

判定路径 → 读 references/ → Qclose-1 → 会话 spec + 路径清单 → 写索引指南 / INDEXING-LOG。

## 边界

| 负责 | 不负责 |
|------|--------|
| 各文档根九章索引指南（index.md / index.md）、INDEXING-LOG、full/incremental、深度 1–3 | 实体与 KNOWLEDGE_INDEX（docs-build）；OKF（docs-okf）；SDD（sdx-*）；overview（distill/extract） |

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. [interaction-gate.md](references/interaction-gate.md)
4. 步骤 1–2：[scan-config-onboarding.md](references/scan-config-onboarding.md)
5. 步骤 4：[scan-spec.md](references/scan-spec.md)
6. 步骤 5：[quality-standards.md](references/quality-standards.md)
7. 步骤 6：[nine-chapter-spec.md](references/nine-chapter-spec.md)
8. [indexing-log-spec.md](references/indexing-log-spec.md)
9. 超范围：[brainstorming-integration.md](references/brainstorming-integration.md)
10. [anti-patterns.md](references/anti-patterns.md)、[gotchas.md](gotchas.md)
11. Spec 模板：[docs-indexing-session-spec-template.md](assets/docs-indexing-session-spec-template.md)

## 门禁

步骤 2 未 Qclose-1（C）不得进扫描/写盘（[workflow.md](references/workflow.md)）。写入须 CONFIRMED + spec 完整根相对路径清单（[gates.md](references/gates.md)）。

## 产出

- Spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`
- 产物：索引指南（如 `index.md` / `index.md`）、`INDEXING-LOG.md`

```bash
agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
```

INDEX 落盘后建议刷新 OKF：见 [docs-okf/references/workflow.md](../docs-okf/references/workflow.md)。

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate indexing`（详 [gates.md](references/gates.md)）。
