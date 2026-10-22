# KNOWLEDGE_TYPE 与 ASD / DSD

读取 `.docsconfig` 的 `KNOWLEDGE_TYPE`，在创建产物前确定层级。布局真源见 [knowledge-layout.md](../../../references/knowledge-layout.md)；本表定义 ASD/DSD 的层级边界。

## 模式

| `KNOWLEDGE_TYPE` | ASD | DSD / 落地 |
| --- | --- | --- |
| `application` 或未设置 | `§1-§3` 完整 | 应用库 `DSD-*.md`；可选概设规约路径见 [工作流](workflow.md#产物路径) |
| `system` | `§1-§3` 联邦概要 | 本库不落 DSD；详设 → 应用库 `/sdx-design` |
| `solution` | 本层不写 ASD | 方案用 `sdx-solution`；ASD/PRD 落实际系统库，DSD 由应用库承接 |
| `company` | 本层不写 ASD | 域架构用 `sdx-domains`；不直拆系统 PRD |

未知值或配置与用户所述层级冲突，先核实；不擅改配置或跨库写入。

## 联邦概要要点

仅适用于 `system`：§1 追溯 PRD 及已读上游；§2 说明能力归属、服务边界、变更方向与上下游；§3 给出规约摘要及下游承接。可用 [承接表片段](../assets/asd-stub-sections-federated.md)，不展开应用实现。

模式只改变内容粒度，不改变 [当前段推进协议](gates.md)。
