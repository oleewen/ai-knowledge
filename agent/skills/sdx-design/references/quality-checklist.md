# DSD 质量验收（sdx-design）

终检前须完成会话总确认；`validate-dsd.sh --file <path> --gate-check` 可核 **CONFIRMED** 与目标 **DSD** 文件名。

**结构**：`## 1`–`## 3` 与 [dsd-template.md](../assets/dsd-template.md) 一致。**完整勾选项**在 DSD 文末 **§3.2**；定稿时将已达标 `- [ ]` 改 `- [x]`。原则见 [design-principles.md](design-principles.md)。

## 摘要（对照 §3.2）

| 维度 | 要点 |
|------|------|
| 结构 | §1–§3 齐；§1 与 ASD §1 **或** `spec-asd-*` §1–2 可追溯 |
| §1 | ANALYSIS/PRD/MVP、约束、DD-n |
| §2 | §2.1–§2.5 完整；每项与 **FR-n / ASD §3 或 spec-asd** 在 §2 内可追溯 |
| §3 | §3.1 历史；§3.2 自查 |
| 一致 | ASD、spec-asd、PRD、knowledge 无未解释冲突 |

**联邦**（KNOWLEDGE_TYPE system/company）：按 [knowledge-type-modes.md](knowledge-type-modes.md) 标 **N/A**。

## 目录自检（细则以 template §3.2 为准）

- [ ] 结构与占位  
- [ ] §1  
- [ ] §2（§2.1–§2.5）  
- [ ] §3 与元数据  

## 原则补充

- [ ] API 命名、版本、错误码符合项目约定（见 design-principles）  
- [ ] 表字段约束已核对或有说明例外  
