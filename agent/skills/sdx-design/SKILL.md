---
name: sdx-design
description: >
  详细设计与规约：以 /sdx-architect 产出的 ASD 为硬输入，编写详细设计说明书 DSD。
  DSD **§1 设计概述**与 [asd-template §1](../sdx-architect/assets/asd-template.md) 对齐（可与 ASD §1 同源复制）；**详细设计正文从 §2 起编号**（§2 详细设计、§3 需求规约、§4 附录），应用全量附带 specs/*.yaml。
  不包含历史「单文档 ADD**：实现级契约仅以 DSD+规约为准。当用户需要 API/DDL、业务逻辑、规约 YAML 或未声明仅架构时务必使用本技能。
  须遵守正文 HARD-GATE：默认禁止在「草稿用户总确认」之前写入 {DOC_DIR}/requirements/**/DSD-*.md。
---

# 详细设计阶段（sdx-design）

独立技能：**不写 ASD**；必须以 **`ASD-{IDEA-ID}-{N}.md`**（`/sdx-architect`）为输入主干。产出 **`DSD-{IDEA-ID}-{N}.md`**：**§1**（设计概述，与 ASD §1/asd-template 同源结构）、**§2–§4**（详细设计起 **§2**、需求规约、附录）；应用全量时同步 **`specs/**/*.yaml`**。读者：**骨干开发、测试设计**。

**上游**：**`sdx-architect`（ASD，必选同 IDEA-ID）**、`sdx-prd`、`sdx-analysis`。**下游**：`sdx-test`。

---

## 知识与库类型

见 **[reference/knowledge-type-modes.md](reference/knowledge-type-modes.md)**。

---

## HARD-GATE

草稿总确认前，**禁止**写入 `{DOC_DIR}/requirements/**/DSD-*.md`。

**合法例外**：用户明示跳过，或 **`SDX_DESIGN_ALLOW_DSD_WRITE=1`**

**门禁标记**：`<!-- sdx-design-gate: PENDING -->` → `CONFIRMED`，正文须含 **`DSD-{IDEA-ID}-{N}.md`** basename。

**规约**：应用全量在总确认后与 DSD 同期落 **`specs/*.yaml`**。

---

## 阶段一：准备

确认：**IDEA-ID**、**ASD 路径**、**KNOWLEDGE_TYPE**、`--depth`；门禁建议 **Gd1–Gd4 ↔ DSD §1–§4**。

---

## 阶段二：会话草稿

路径：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-design.md`。骨架：**[assets/design-session-spec-template.md](assets/design-session-spec-template.md)**。

| 门禁 | DSD 章节 |
|------|-----------|
| Gd1 | §1 设计概述（对齐 [asd-template §1](../../sdx-architect/assets/asd-template.md) / ASD §1） |
| Gd2 | §2 详细设计 |
| Gd3 | §3 需求规约 |
| Gd4 | §4 附录 |

标准四选项 **C/M/S/F**。brainstorming 见 [reference/brainstorming-integration.md](reference/brainstorming-integration.md)。

**总确认**：是否以此草稿生成 **`DSD-{IDEA-ID}-{N}.md`**？

---

## 阶段三：定稿

在同目录 **`DSD-{IDEA-ID}-{N}.md`**，按 **[assets/dsd-template.md](assets/dsd-template.md)**。**§1** 必须与 ASD **协调一致**（复制或可追溯摘要）。

应用全量：**从 §2** 抽出 **`specs/{service}/{type}/`**。

**终检**：[reference/quality-checklist.md](reference/quality-checklist.md)。

```bash
agent/skills/sdx-design/scripts/validate-dsd.sh
agent/skills/sdx-design/scripts/validate-dsd.sh --file path/to/DSD-xxx.md --gate-check
```

`validate-design.sh` 等价于 `validate-dsd.sh`。

---

## 参考资源

| 资源 | 路径 |
|------|------|
| ASD §1 / 上游结构 | [../sdx-architect/assets/asd-template.md](../sdx-architect/assets/asd-template.md) |
| DSD 模板（§1+§2–§4） | [assets/dsd-template.md](assets/dsd-template.md) |

---

## 工程化支持

`python3 agent/hooks/sdx_gate_common.py --gate design`（**DSD-***）
