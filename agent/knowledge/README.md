# agent/knowledge — 知识库治理 SSOT

本目录承载原 `*/constitution/` 迁移内容：术语、命名、原则与 ADR 约定。协作闸门与编码规范仍在 [../rules/CONVENTIONS.md](../rules/CONVENTIONS.md)。

## 组件

| 文件 | 说明 |
| --- | --- |
| [knowledge-governance.md](knowledge-governance.md) | 三层知识库治理边界与使用顺序 |
| [naming-conventions.md](naming-conventions.md) | 实体 ID 命名规范（全局 SSOT） |
| [glossary.md](glossary.md) | 全局术语表 |
| [architecture-principles.md](architecture-principles.md) | 架构原则条目 |
| [adr-template.md](adr-template.md) · [adr-guidelines.md](adr-guidelines.md) | ADR 模板与落盘约定 |
| [application/adr/](../../application/adr/README.md) · [system/adr/](../../system/adr/README.md) | ADR 正文目录（按决策范围分域） |

## 使用顺序

1. 新词 / 歧义 → [glossary.md](glossary.md)
2. 新实体 / 文件 → [naming-conventions.md](naming-conventions.md)
3. 跨域或长期后果的决策 → [application/adr/](../../application/adr/README.md) 或 [system/adr/](../../system/adr/README.md)，按 [adr-template.md](adr-template.md)
