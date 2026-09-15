---
name: docs-distill
description: >
  将联邦槽位已核实内容全量去重后以 delta 写入目标层 overview 第三列：
  application-slots → system/knowledge/overview；system-slots → company/knowledge/overview。
  蒸馏前须契约级摸清目标/源职责范围与知识要点粒度，不清则硬停决策并先落盘；仅全量；不写 DISTILL-LOG。细则 federation-spec、scope-clarity。
  用户提到 /docs-distill、知识蒸馏、槽位上行、联邦蒸馏、同步应用到系统 overview、同步系统到公司 overview、
  更新系统库/公司库 overview、某应用或系统知识改了要同步、看看要同步哪些内容、蒸馏前职责边界/粒度不清时，务必使用本技能。
  分流：任意非槽位源提炼 → docs-extract；overview 归档 → docs-archive；INDEX → docs-indexing；SDD → 对应技能。
  推进见 references/gates.md。
---

# docs-distill

## 输出硬约束（P0）

- 当前单元：单个 `{NAME}-overview.md` + **仅全量**范围（可含 `--dry-run` 预览）。
- 写前澄清 / 推进环 `C/M/G/S/F` / 烤干 → [intent-clarify.md](../../references/intent-clarify.md)、[unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)、[grilling-skill.md](../../references/grilling-skill.md)、[simplify-principles.md](../../references/simplify-principles.md)；细节 [gates.md](references/gates.md)。未获写前 `C` 不得写入或输出正式预览结论；写入或 `--dry-run` 预览后均须烤干，收敛后停等用户。
- **职责/粒度闭合（写前 `C` 内）**：蒸馏前须按 [scope-clarity.md](references/scope-clarity.md) 摸清目标层与源槽位职责、要点粒度与跨层收束；只信落盘契约。缺失/模糊/双边冲突 → 硬停决策 → **先落盘契约** → 再出职责/粒度短摘要；未闭合不算写前 `C`，不得 dry-run / 写入。此为契约级闭合，**不等于**写后 grilling。
- **边**：`DOC_DIR=system` → 读 `system/application-slots/application-{NAME}/`，写 `system/knowledge/overview/{NAME}-overview.md`；`DOC_DIR=company` → 读 `company/system-slots/system-{NAME}/`，写 `company/knowledge/overview/{NAME}-overview.md`。应用层无 overview，不作目标。
- **DOC_DIR**：优先 `.docsconfig` / 环境变量；须为 `system|company`；否则参数向导必选。`--doc-dir` 可显式覆盖。
- **模式**：仅全量；不写 `DISTILL-LOG`；无 `--since` / 增量锚点。`--dry-run`：三分区预览，不写 overview。
- **第三列**：去重后仅写 delta；[federation-spec.md](references/federation-spec.md)（表行随目标层）。
- **knowledge 引用边界**：写入 `system|company/knowledge/**` 须遵守 [knowledge-governance.md](../../knowledge/knowledge-governance.md)「业务 knowledge 引用边界」。可读槽位外源；落盘 overview 不链外源路径、不链下层/槽位、禁手写爬层。有 parent 则上层实体用生成函数 HTTP，否则纯 ID。违规能修则修，不明则停。

## 边界

- 负责：联邦槽位 → 目标层 overview 第三列（全量）；写前职责/粒度契约闭合；当前单元推进
- 不负责：非槽位任意源（→ docs-extract）；docs-archive；docs-indexing；SDD 终稿代写；DISTILL-LOG；写后成品深挖（→ grilling）

## 不这样用

- 不走前置草稿 + 集中收口；默认参数向导后「澄清 → 生成 → 烤干」
- 不把写前职责/粒度闭合当成完整 grilling Skill 深挖；也不跳过契约清单去「猜」职责
- 不把本技能偷换成 `docs-extract`、`docs-archive` 或 `docs-indexing`
- 不用非槽位 path 直蒸；槽位空/未 pull 则停
- 契约未闭合时不做 dry-run、不写第三列；人口头答复未落盘不当闭合

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 推进 binding | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 职责与粒度闭合 | [scope-clarity.md](references/scope-clarity.md) |
| 受众与语言 | [audience-and-language.md](references/audience-and-language.md) |
| 核心概念 | [core-concepts.md](references/core-concepts.md) |
| 蒸馏规范 | [distill-spec.md](references/distill-spec.md) |
| 联邦规则 | [federation-spec.md](references/federation-spec.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 可确定的 `DOC_DIR`（`system|company`）
- 可定位的槽位与 `--name`
- 是否只做 `--dry-run`
- 目标层 `knowledge/overview/` 可写

## 产出与脚本

- 正式：目标层 `knowledge/overview/{NAME}-overview.md` 第三列
- 不写任何 DISTILL-LOG
- 收敛后动作见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)（本技能有 `S`）

```bash
agent/skills/docs-distill/scripts/run-docs-distill.sh --help
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。
