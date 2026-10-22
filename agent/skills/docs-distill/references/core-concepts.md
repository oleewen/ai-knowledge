# 核心概念

| 术语 | 定义 |
| --- | --- |
| `DOC_DIR` | 目标层：`system`、`solution` 或 `company`；`application` 不属于蒸馏目标 |
| `{NAME}` | `system` 边为应用名，`solution` 边为系统名，`company` 边为解决方案名 |
| 源槽位 | 与 `DOC_DIR` 对应的联邦槽位，见 [workflow.md](workflow.md) |
| `{NAME}-overview.md` | 目标层 `knowledge/overview/` 下的单元文件 |
| 全量 | 每次扫描槽位内全部已核实内容，再与第三列比对 |
| delta | 只写目标第三列未覆盖或已变更的要点；规则见 [federation-spec.md](federation-spec.md) |

`DISTILL-LOG` 与 `--since` 已废止。职责和粒度不是从正文猜出的结论，必须来自 [scope-clarity.md](scope-clarity.md) 的落盘契约。
