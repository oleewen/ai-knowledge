# 核心概念

| 术语 | 定义 |
| --- | --- |
| `DOC_DIR` | 实际文档相对目录；与 `KNOWLEDGE_TYPE` 分开解析 |
| `KNOWLEDGE_TYPE` | 目标层 system / solution / company；application 不属于蒸馏目标 |
| `{NAME}` | `system` 边为应用名，`solution` 边为系统名，`company` 边为解决方案名 |
| 源槽位 | 由知识层决定前缀、位于 `DOC_DIR` 下的联邦槽位，见 [workflow.md](workflow.md) |
| `{NAME}-overview.md` | 目标层 `knowledge/overview/` 下的单元文件 |
| 全量 | 每次扫描槽位内全部已核实内容，再与目标知识正文比对；旧第三列用于保留/更新待归档工作 |
| delta | 只写目标第三列未覆盖或已变更的要点；规则见 [federation-spec.md](federation-spec.md) |

`DISTILL-LOG` 与 `--since` 已废止。职责和粒度不是从正文猜出的结论，必须来自 [scope-clarity.md](scope-clarity.md) 的落盘契约。
