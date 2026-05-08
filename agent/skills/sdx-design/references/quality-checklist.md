# 详细设计质量验收清单（sdx-design / DSD）

> **闸门式工作流**：终检前须已完成会话 spec 用户总确认（见 [SKILL.md](../SKILL.md)）；`validate-dsd.sh --file <path> --gate-check` 可核对 `CONFIRMED` 与该 **DSD** 文件名。

**正文结构**： **`## 1`–`## 4`**（§1 设计概述 + §2–§4 与 [dsd-template.md](../assets/dsd-template.md) 一致）。**完整自检表**见 **同一 DSD** 文末 **§4.2**。下表为执行摘要。**定稿**时在正文 §4.2 将已达标 `- [ ]` → `- [x]`，不得虚假勾选。

规范层原则与反模式见 [design-principles.md](design-principles.md)。

---

## 摘要维度（对照 dsd §4.2）

| 维度 | 通过要点 |
|------|----------|
| 结构与占位 | **`## 1`–`## 4`** 齐全；§1 与 **ASD §1 / asd-template** 或 **仅有 `specs/spec-asd-{IDEA-ID}-{N}-{app-name}.md` 时** 与该文件 §1–2 **可追溯对齐** |
| §1 设计概述 | ANALYSIS/PRD/MVP；约束；DD-n |
| §2 详细设计 | §2.1～§2.5：**API-n**、DDL、非功能等与 §3 规约表及 `specs/spec-dsd-{IDEA-ID}-{N}-{MS-ID}.md`（适用时）可追溯 |
| §3 需求规约 | 表中 `./specs/spec-dsd-{IDEA-ID}-{N}-{MS-ID}.md` 与磁盘一致；应用全量时该 Markdown 与 [dsd-spec-template.md](../assets/dsd-spec-template.md) 骨架一致且与 DSD §2 互指 |
| §4 附录 | §4.1 历史；§4.2 自查 |
| 一致性 / 可追溯 / 可行性 / 术语 / 元数据 | 与 **ASD、架构规约 `spec-asd-*`、详设规约 `spec-dsd-*`、PRD、KNOWLEDGE** 无未说明冲突 |

**联邦概要**（`KNOWLEDGE_TYPE` system/company）：按 [knowledge-type-modes.md](knowledge-type-modes.md) 标 **N/A**。

---

## 逐项核对目录（以 dsd-template §4.2 条目标题为准）

- [ ] **结构与占位**
- [ ] **§1 设计概述**（有 ASD 则对齐 ASD §1；仅有 `specs/spec-asd-{IDEA-ID}-{N}-{app-name}.md` 则对齐该文件 §1–2 并标注 SSOT）
- [ ] **§2 详细设计**（§2.1～§2.5）
- [ ] **§3 需求规约**
- [ ] **§4 附录与元数据**

（细则仍以 [../assets/dsd-template.md](../assets/dsd-template.md) §4.2 *通过标准* 为准。）

---

## 原则层补充

- [ ] API 命名、版本与错误码风格符合项目约定（见 [design-principles.md](design-principles.md)）
- [ ] 数据表命名、`gmt_create`/`gmt_modified` 等字段约束已核对或已说明例外
