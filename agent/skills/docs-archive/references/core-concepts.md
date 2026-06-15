# 核心概念

布局契约：[knowledge-layout.md](../../../references/knowledge-layout.md)。闸门 [gates.md](gates.md)；步骤 [workflow.md](workflow.md)。

## overview 语法

`{overview}` 或 `{overview}#{章节或锚点}`

| 字段 | 含义 | 例 |
| ------ | ------ | --- |
| overview | 必填，仓库内路径 | `system/architecture/overview/billing-overview.md`；公司侧 `company/ea/overview/COMPANY-overview.md` |
| 锚 | 可选，只归档该范围 | `#支付域` |

## 目标路径（overview 驱动）

- 目标 = 表格**行内副标题链接**；**不**另接用户手写目标（非标准路径须在确认书写明）。
- 表行范围与对应层 `overview/NAME-overview.md` 及各视角 **README 表行**一致；副标题锚点须与各章节 `##` 标题对齐。
- 路径有空格加引号。
- **缺链** → 写入冲突清单并请用户决策，勿猜；可先对照 README 表行与章节 H2 排查。
- 解析结果写入确认书，不单靠口头。

## 「来源—目标」简写

先解析两端再读文件；`-`/空格/数字邻接易误切 → 用 `→`、`到` 或引号；详见 [gotchas.md](../gotchas.md)。
