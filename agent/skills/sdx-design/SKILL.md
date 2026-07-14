---
name: sdx-design
description: >
  基于已共识 PRD 与 ASD/spec-asd 按 §1-§3 分段细化实现级设计，并直写 DSD-{IDEA-ID}-{N}.md；
  每段生成后自动 grilling 补强至收敛，用户确认后再推进下一段。
  触发：/sdx-design、编写/修改 DSD、API、DDL、错误码、幂等、时序、validate-dsd，且可对齐上游 ASD 或 spec-asd。
  分流：只要 PRD/ASD/TDD/docs-* 主路径 → 对应技能。
  推进协议：参数向导、当前段、自动 grilling、前文回改与用户动作见 references/gates.md。
compatibility: Bash 5+；校验脚本 agent/skills/sdx-design/scripts/validate-dsd.sh（仅结构/内容校验）。
---

# sdx-design

读 references/ → 参数向导 → 分段直写终稿 → 每段自动 grilling 补强至收敛 → 用户确认推进。无 PRD → 引导 `sdx-prd`；无 ASD/spec-asd → 引导 `sdx-architect` 或按缺口标注受限继续。**不写 ASD，不产 TDD。**

## 输出硬门禁（P0）

- 一次只处理一个“当前段”（章节、子章节、单个 `API` 契约块、单个 `DDL/TBL` 块、单个 `LOGIC` 块、单个错误码组、单个幂等/时序/安全策略块）；禁止一口气补齐多段。
- 当前段写入终稿后，必须进入自动 `grilling` 循环；仅当当前段已收敛，或打出必须等待用户确认的语义性问题时，才把控制权交还用户。
- 自动 `grilling` 收敛后，输出 `C/M/G/F` 选项并停止等待用户选择；不得自动推进下一段。
- `F` 仅表示在当前段已收敛后，一次性补齐当前文档剩余未完成章节；不得覆盖已确认前文。
- 若用户一开始就要求“一次性生成整篇”，仍先完成当前段并自动 `grilling` 至收敛，再由用户明确选择 `F` 进入批量补齐。
- `grilling` 过程中如发现**语义性问题**（改变接口语义、数据模型、服务边界、幂等策略、错误码口径、事务边界、非功能取舍、优先级、术语等），必须先给出结论、推荐修订与数字选项并等待用户确认；未获确认不得修订当前段。
- 仅**非语义性修订**（不改变含义的错别字、编号、排版等）可在当前段默认授权下直接修订；不确定时按语义性处理。

## 边界

| 负责 | 不负责 |
| --- | --- |
| `DSD-{IDEA-ID}-{N}.md` 生成与推进、§1-§3 详设、§2 实现级 API/DDL/LOGIC/错误码/幂等/时序设计 | `PRD/ASD/TDD/SOLUTION/ANALYSIS` 初稿；docs-* 主路径；实现代码与自动化测试 |

## 不这样用

- 不走前置草稿 + 集中收口主线；主线是参数向导后直接分段直写终稿
- 不把整篇集中回炉或整份重生成当默认路径
- 不把 `DSD` 阶段偷换成 `ASD/PRD/TDD` 或 docs-* 主路径
- 不把实现级契约拆到 DSD 外的第二份 Markdown 作为并行正文

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| grilling 能力 | [grilling-skill.md](../../references/grilling-skill.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 易错 / 受众 / 终检 | [gotchas.md](gotchas.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| KNOWLEDGE_TYPE | [knowledge-type-modes.md](references/knowledge-type-modes.md) |
| 模板 | [dsd-template.md](assets/dsd-template.md)、上游 [asd-spec-template.md](../sdx-architect/assets/asd-spec-template.md) |

## 最少输入

- 可对齐的 **`PRD-{IDEA-ID}-{N}.md`**
- 可对齐的 **`ASD-{IDEA-ID}-{N}.md`** 和/或 `spec-asd-{IDEA-ID}-{N}-{app-name}.md`
- `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 可写
- 若已给 `IDEA-ID`、`N`、章节范围、深度、上游文档范围，则直接进入参数向导确认

## 推进协议

段落推进、前文回改、自动 `grilling` 与用户动作 `C/M/G/F` 见 [gates.md](references/gates.md)。

## 产出与校验

- 正式：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-design/scripts/validate-dsd.sh
agent/skills/sdx-design/scripts/validate-dsd.sh --file path/to/DSD-xxx.md
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。
`sdx-design` 评测聚焦当前段推进协议与结构校验。
