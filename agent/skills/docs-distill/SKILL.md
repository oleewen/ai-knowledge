---
name: docs-distill
description: >
  将 system/application-{name}/ 已核实内容蒸馏写入 system/knowledge/overview/{APPNAME}-overview.md 第三列，
  并在 overview 成功写入后追加 DISTILL-LOG；按「澄清 → 生成 → 烤干」处理单个 overview 当前单元。
  触发：/docs-distill、「知识蒸馏」「更新 overview」「同步应用知识」等。
  分流：用户只要 docs-extract/archive/indexing 或仅 SDD → 对应技能。
  推进协议：参数向导、写前意图澄清、当前单元、烤干、C/M/G/S/F 见 references/gates.md 与 references/workflow.md。
---

# docs-distill

读 references/ → 参数向导 → 分段「澄清 → 生成 → 烤干」→ 用户动作推进。
主路径是“应用知识蒸馏到系统 overview 第三列”，并在成功写入后追加 `DISTILL-LOG`。

## 输出硬门禁（P0）

- 一次只处理一个“当前单元”：单个 `{APPNAME}-overview.md` 目标 + 单次增量范围或单次全量预览范围；禁止一口气补齐多个应用（除非用户显式 `F` 且已完成剩余单元意图批确认）。
- 当前单元**写入/预览前**必须完成**意图澄清**（公共六项 + 阶段横幅「当前阶段：意图澄清」）；未获写前 `C` 不得写入 overview 或输出正式预览结论。契约见 [intent-clarify.md](../../references/intent-clarify.md)。
- 当前单元完成 overview 写入或 `--dry-run` 预览后，必须立刻进入自动 `grilling`（烤干）循环；当前单元未收敛前，不得自动推进下一应用或下一批范围。
- 自动 `grilling` 收敛后，输出 `C/M/G/S/F` 选项并停止等待用户选择；须标明「当前阶段：烤干」；不得自动推进下一应用。
- `C` 同符异义：意图澄清阶段 = 授权写入/预览；烤干阶段 = 确认本单元并推进。禁止无阶段横幅裸发动作字母。
- `F` 仅表示在当前单元已收敛后，先批确认剩余未完成应用/范围意图，再一次性补齐；不得跳过意图批确认。
- 语义性变更（目标 app、时间范围、全量/增量策略、冲突口径、是否首次建 overview 等）必须先给出结论、推荐方案与数字选项；未获确认不得执行写入。
- `DISTILL-LOG` 只能在 overview 第三列成功写入后追加；overview 写入失败时，禁止记录日志。
- `--dry-run` 仍须写前意图澄清；只做当前单元预览，不写 overview，不写 `DISTILL-LOG`；烤干可针对预览结果。

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
| 推进协议 | [gates.md](references/gates.md) |
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

## 推进协议

意图澄清、单元推进、烤干与用户动作 `C/M/G/S/F` 见 [gates.md](references/gates.md)。

## 产出与脚本

- 正式：`system/knowledge/overview/{APPNAME}-overview.md` 第三列
- 正式：`system/changelogs/DISTILL-LOG.md`（overview 成功后）

```bash
agent/skills/docs-distill/scripts/run-docs-distill.sh --help
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
评测重点：写前意图澄清、单单元停顿、overview 成功后再写 `DISTILL-LOG`、`--dry-run` 不落盘。
