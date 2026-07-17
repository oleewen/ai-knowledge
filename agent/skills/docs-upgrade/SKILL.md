---
name: docs-upgrade
description: >
  定向改 Markdown、注释、配置文本；统一术语并沿引用链 + 关键词链式同步。
  按当前单元执行「澄清 → 生成 → 烤干」：写前意图澄清，写入后自动 grilling 至收敛。
  触发：/docs-upgrade、「改文档」「统一术语」「把 X 换成 Y」；简写 a - b / a > b / a 2 b 均为 a→b。
  分流：用户只要 docs-archive/change/indexing/build 或仅 CHANGE-LOG/INDEX → 对应技能。
  推进协议：参数向导、意图澄清、当前单元、烤干与用户动作 C/M/G/S/F 见 references/gates.md。
---

# docs-upgrade：定向升级与链式对齐

判定归属 → 读 references/ → 参数向导 → 按当前单元执行 **澄清 → 生成 → 烤干** → 用户动作推进。

## 输出硬约束（P0）

- 一次只处理一个“当前单元”：单个主文件，或单个已确认关联批次（除非用户显式 `F` 且已完成剩余意图批确认）。
- 当前单元**写入前**必须完成**意图澄清**（公共六项 + 阶段横幅「当前阶段：意图澄清」）；未获写前 `C` 不得写入主文件或扩展到关联文件。契约见 [intent-clarify.md](../../references/intent-clarify.md)。
- 范围确认书须并入公共六项，作为写前意图澄清容器；快路径（单点、用户已限「仅本文件」）可一屏六项摘要后写前 `C`。
- 当前单元写入后，必须进入自动 `grilling`（烤干）；本技能**默认必须烤干**；未收敛前，不得自动推进下一批关联文件。
- 自动 `grilling` 收敛后，输出 `C/M/G/S/F` 并停止等待用户选择；须标明「当前阶段：烤干」；`C` 同符异义，靠阶段横幅区分。
- 语义性变更（术语边界、引用链影响面、关键词扩展范围、是否只改本文件）必须先给出结论、推荐方案与数字选项；未获确认不得执行。
- 用户明示“只改本文件 / 不要关联 / 不要全库搜”时，不得静默重开链式扩展。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| MD/注释/配置文档性文本；引用链 + 关键词；意图澄清与范围收口 | docs-change、docs-indexing、docs-archive、docs-build 主流程 |

## 不这样用

- 不走「范围确认后直接写、跳过意图澄清」的旧主线
- 不在用户已限定“只改本文件”时强制扩展整条引用链
- 不把 CHANGE-LOG 聚合、INDEX 重建、overview 行归档、实体索引主路径收成 `docs-upgrade`
- 不把写前意图澄清称作 grilling；`G` 仅写后深挖

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| 范围模板 | [docs-upgrade-scope-ack-template.md](assets/docs-upgrade-scope-ack-template.md) |
| 关联发现 | [related-doc-discovery.md](references/related-doc-discovery.md)、[semantic-keyword-discovery.md](references/semantic-keyword-discovery.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 主目标文件或可确认的候选范围
- 改动摘要或术语替换目标
- 是否允许关联扩展已收口
- 若涉及术语或路径迁移，语义边界已确认

## 当前单元

- 单个主文件
- 单个已确认关联批次
- 单个回链修复批次

当前单元烤干收敛后，由用户用 `C/M/G/S/F` 推进（须打印阶段横幅）：

- `C`：确认当前单元并进入下一批或结束
- `M`：修改范围、术语边界或同步策略，再重新烤干
- `G`：继续深挖当前单元的引用链或关键词覆盖（仅写后）
- `S`：暂存当前单元，跳过关联扩展或写入
- `F`：在当前单元已收敛后，先批确认剩余单元意图，再按既定范围补齐

## 产出

已改主文件与已确认关联；链校验见 quality-checklist。

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。无专用 preToolUse 钩子。
评测重点：意图澄清、单单元「澄清→生成→烤干」、语义扩展确认、链式同步边界。
