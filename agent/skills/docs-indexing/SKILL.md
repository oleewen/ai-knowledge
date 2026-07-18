---
name: docs-indexing
description: >
  生成九章索引指南（各文档根固定为 INDEX-GUIDE.md），维护各 DOC_DIR 下 changelogs/INDEXING-LOG.md 主表（最新在上）。
  触发：/docs-indexing、建/更索引、文档地图、Onboarding、口述「整理 INDEX」。
  分流：用户只要 docs-build/distill/extract/SDD 为主路径 → 对应技能，勿单跑本技能。
  推进协议：参数向导、当前单元、自动 grilling、C/M/G/S/F 见 references/gates.md、intent-clarify、unit-cycle-protocol、grilling-skill。
---

# docs-indexing

主路径：生成单个索引输出组并维护对应 `INDEXING-LOG.md`。

## 输出硬约束（P0）

- 当前单元：单个索引输出组（如根或某 `DOC_DIR` 的 `INDEX-GUIDE.md` + 对应 `INDEXING-LOG.md`）。
- 写前意图澄清 → [intent-clarify.md](../../references/intent-clarify.md)；未获写前 `C` 不得写入。
- 推进环 `C/M/G/S/F` → [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)。
- 烤干 → [grilling-skill.md](../../references/grilling-skill.md)；收敛后停等用户，不得自动推进下一输出组。
- 意图澄清第 6 项须列出本轮双路径（仓库根相对）：`INDEX-GUIDE.md` 与对应 `changelogs/INDEXING-LOG.md`。
- 无基线且请求 incremental 时，须先确认 full/中止/补 since，不得静默继续。

## 边界

- 负责：各文档根 `INDEX-GUIDE.md`、`INDEXING-LOG.md`、full/incremental、深度 1–3
- 不负责：实体与 `KNOWLEDGE_INDEX`（docs-build）；OKF（docs-okf）；SDD；overview（distill/extract）

## 不这样用

- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `docs-indexing` 偷换成 `docs-build`、overview 或 SDD 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| 参数与基线 | [scan-config-onboarding.md](references/scan-config-onboarding.md) |
| 扫描规范 | [scan-spec.md](references/scan-spec.md) |
| 质量与九章 | [quality-standards.md](references/quality-standards.md)、[nine-chapter-spec.md](references/nine-chapter-spec.md) |
| 日志规范 | [indexing-log-spec.md](references/indexing-log-spec.md) |
| 易错 / 反模式 | [anti-patterns.md](references/anti-patterns.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 仓库根可解析
- `mode`、`depth` 已收口
- `output` 与 `since` 策略已收口
- 若增量模式，已确认基线策略

## 当前单元

- 单个索引输出组

收敛后用户动作见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)；本技能有 `S`。

## 产出

- 产物：索引指南（固定为 `INDEX-GUIDE.md`）、`INDEXING-LOG.md`

```bash
agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
```

INDEX 落盘后建议刷新 OKF：见 [docs-okf/references/workflow.md](../docs-okf/references/workflow.md)。

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。
评测重点：意图澄清、单单元停顿、路径/容器双路径、基线异常不静默降级。
