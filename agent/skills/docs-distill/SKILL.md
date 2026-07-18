---
name: docs-distill
description: >
  将 system/application-{name}/ 已核实内容蒸馏写入 system/knowledge/overview/{APPNAME}-overview.md 第三列，
  并在 overview 成功写入后追加 DISTILL-LOG。
  触发：/docs-distill、「知识蒸馏」「更新 overview」「同步应用知识」等。
  分流：用户只要 docs-extract/archive/indexing 或仅 SDD → 对应技能。
  推进协议：参数向导、当前单元、自动 grilling、C/M/G/S/F 见 references/gates.md、intent-clarify、unit-cycle-protocol、grilling-skill。
---

# docs-distill

主路径：应用知识蒸馏到系统 overview 第三列；成功写入后追加 `DISTILL-LOG`。

## 输出硬约束（P0）

- 当前单元：单个 `{APPNAME}-overview.md` + 单次增量/全量预览范围。
- 写前意图澄清 → [intent-clarify.md](../../references/intent-clarify.md)；未获写前 `C` 不得写入或输出正式预览结论。
- 推进环 `C/M/G/S/F` → [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)。
- 烤干 → [grilling-skill.md](../../references/grilling-skill.md)；写入或 `--dry-run` 预览后均须烤干；收敛后停等用户。
- **原子性**：`DISTILL-LOG` 仅在 overview 第三列成功写入后追加；写入失败禁止记日志。`--dry-run` 仍须写前澄清，不写 overview / `DISTILL-LOG`。

## 边界

- 负责：已核实应用 -> overview 第三列；增量/全量；`DISTILL-LOG`；当前单元推进
- 不负责：docs-extract；docs-archive；docs-indexing；SDD 终稿代写

## 不这样用

- 不走前置草稿 + 集中收口主线；主线是参数向导后分段「澄清 → 生成 → 烤干」
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `docs-distill` 偷换成 `docs-extract`、`docs-archive` 或 `docs-indexing`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| 核心概念 | [core-concepts.md](references/core-concepts.md) |
| 蒸馏规范 | [distill-spec.md](references/distill-spec.md)、[distill-log-spec.md](references/distill-log-spec.md) |
| 联邦规则 | [federation-spec.md](references/federation-spec.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 可定位的应用目录或 `--app`
- 可确定的增量起点：自动锚点或显式 `--since`
- 是否 `--full`
- 是否只做 `--dry-run`
- `system/knowledge/overview/` 与 `system/changelogs/` 可写

## 当前单元

- 单个 `{APPNAME}-overview.md` + 单次范围

收敛后用户动作见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)；本技能有 `S`。

## 产出与脚本

- 正式：`system/knowledge/overview/{APPNAME}-overview.md` 第三列
- 正式：`system/changelogs/DISTILL-LOG.md`（overview 成功后）

```bash
agent/skills/docs-distill/scripts/run-docs-distill.sh --help
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
评测重点：写前意图澄清、单单元停顿、overview 成功后再写 `DISTILL-LOG`、`--dry-run` 不落盘。
