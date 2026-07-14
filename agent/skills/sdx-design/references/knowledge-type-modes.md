# KNOWLEDGE_TYPE 与 DSD

**来源**：`.docsconfig` 的 `KNOWLEDGE_TYPE`。布局契约见 [knowledge-layout.md](../../../references/knowledge-layout.md)。

## 模式

| `KNOWLEDGE_TYPE` | DSD |
| --- | --- |
| `application` 或未设置 | `DSD-{IDEA-ID}-{N}.md` 为唯一正式详设正文 |
| `system` / `company` | 原则上不在本层落 DSD；若用户显式要求，需先确认是否实际应回应用库执行 `/sdx-design` |

## 约束

- `sdx-design` 默认面向应用库详设正文
- `system/company` 更常见的是停在 `ASD` 联邦概要，由应用库承接 DSD
- 本层继续沿用参数向导 + 分段直写 + 当前段 `C/M/G/F` 推进
