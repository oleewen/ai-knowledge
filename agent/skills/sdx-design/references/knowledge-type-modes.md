# KNOWLEDGE_TYPE 与 DSD

先读取 `.docsconfig`。层级和阶段目录以 [knowledge-layout.md](../../../references/knowledge-layout.md) 为准。

| `KNOWLEDGE_TYPE` | 执行落点 |
| --- | --- |
| `application` 或未设置 | 沿应用模式，将 DSD 写入已确认文档根的 `requirements/` |
| `system` | 系统层承接 PRD/ASD；确认负责应用及其路径，由应用库展开 DSD，不自动在系统库落详设 |
| `solution` | 本层只有 `solutions/` 交付阶段；定位负责应用，不创建 `requirements/` |
| `company` | 本层只有 `domains/` 交付阶段；定位负责应用，不创建 `requirements/` |

用户指定的目标若与配置冲突，先确认实际执行库；不静默改配置或推断应用目录。只读校验用户点名的已有 DSD 不改变其落点。
