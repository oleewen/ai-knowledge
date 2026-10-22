# sdx-architect 概念反模式

| 反模式 | 纠正依据 |
| --- | --- |
| 没有 PRD，用架构假设代替需求 | 补齐同链 PRD 或转 `sdx-prd`；见 [输入条件](workflow.md#参数向导) |
| 把 ASD 写成 DSD，或复制 PRD 全文 | 只写架构决定及协议摘要；见 [受众边界](audience-and-language.md) |
| 把所有上层库都视作联邦 ASD | 仅系统库使用联邦概要；见 [类型模式](knowledge-type-modes.md) |
| 认为 `F` 授权重写已确认前文 | 按 [单元推进](../../../references/unit-cycle-protocol.md) 区分补齐与重开 |
| 把三章编号、`G1-G3` 或每轮选 `G` 当流程门禁 | 当前段权限只按 [gates.md](gates.md)；章节编号是内容结构 |
| 有模板或脚本通过，就宣称架构已确认 | 按 [质量清单](quality-checklist.md) 核对语义、来源和授权证据 |

命令与路径陷阱见 [gotchas.md](../gotchas.md)。
