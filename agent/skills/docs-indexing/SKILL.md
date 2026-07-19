---
name: docs-indexing
description: >
  生成九章索引指南（各文档根固定为 INDEX-GUIDE.md），维护各 DOC_DIR 下 changelogs/INDEXING-LOG.md 主表（最新在上）。
  用户提到 /docs-indexing、建/更索引、文档地图、Onboarding、整理 INDEX 时，使用本技能。
  分流：实体/KNOWLEDGE_INDEX → docs-build；overview → docs-distill/extract；SDD → 对应技能，勿单跑本技能吞下游。
  推进见 references/gates.md。
---

# docs-indexing

## 输出硬约束（P0）

- 当前单元：单个索引输出组（如根或某 `DOC_DIR` 的 `INDEX-GUIDE.md` + 对应 `INDEXING-LOG.md`）。
- 写前澄清 / 推进环 `C/M/G/S/F` / 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)；细节 [gates.md](references/gates.md)。未获写前 `C` 不得写入；收敛后停等用户，不得自动推进下一输出组。
- 意图澄清第 6 项须列出本轮双路径（仓库根相对）：`INDEX-GUIDE.md` 与对应 `changelogs/INDEXING-LOG.md`。
- 无基线且请求 incremental 时，须先确认 full/中止/补 since，不得静默继续。

## 边界

- 负责：各文档根 `INDEX-GUIDE.md`、`INDEXING-LOG.md`、full/incremental、深度 1–3
- 不负责：实体与 `KNOWLEDGE_INDEX`（docs-build）；OKF（docs-okf）；SDD；overview（distill/extract）

## 不这样用

- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把本技能偷换成 `docs-build`、overview 或 SDD 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 参数与基线 | [scan-config-onboarding.md](references/scan-config-onboarding.md) |
| 扫描规范 | [scan-spec.md](references/scan-spec.md) |
| 质量与九章 | [quality-standards.md](references/quality-standards.md)、[nine-chapter-spec.md](references/nine-chapter-spec.md) |
| 日志规范 | [indexing-log-spec.md](references/indexing-log-spec.md) |
| 易错 / 反模式 | [anti-patterns.md](references/anti-patterns.md)、[gotchas.md](gotchas.md) |
| 模板 | [index-guide-template.md](assets/index-guide-template.md) |

## 最少输入

- 仓库根可解析
- `mode`、`depth` 已收口
- `output` 与 `since` 策略已收口
- 若增量模式，已确认基线策略

## 产出与脚本

- 正式：索引指南（固定为 `INDEX-GUIDE.md`）、`INDEXING-LOG.md`
- 收敛后动作见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)（本技能有 `S`）
- INDEX 落盘后建议刷新 OKF：见 [docs-okf/references/workflow.md](../docs-okf/references/workflow.md)

```bash
agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。
