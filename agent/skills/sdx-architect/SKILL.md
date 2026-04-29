---
name: sdx-architect
description: >
  架构设计阶段：基于 PRD 产出架构设计说明书 ASD（§1 设计概述、§2 架构设计）。
  当用户执行 /sdx-architect、需要写 ASD、画服务边界与架构图、整理服务变更表、或 KNOWLEDGE_TYPE 为 system/company 的联邦概要时，务必使用本技能。
  详细设计（API/DDL/逻辑/规约 YAML）不在本技能范围，由下游 /sdx-design 产出 DSD。
  须遵守正文 HARD-GATE：默认禁止在「草稿用户总确认」之前写入 {DOC_DIR}/requirements/**/ASD-*.md。
---

# 架构设计阶段（sdx-architect）

产出**架构设计说明书（ASD）**：**§1、§2**。与 PRD、分析文档对齐，为下游 **DSD**（`/sdx-design`）提供边界、服务级变更与引用链。主要读者：**架构师、技术负责人**。

**上游**：`sdx-prd`（必需）、`sdx-analysis`（推荐）。**下游**：`sdx-design`（同目录 `DSD-{IDEA-ID}-{N}.md`）。

---

## 知识与库类型

执行**阶段一**时读取 `.docsconfig` 中的 **`KNOWLEDGE_TYPE`**。规则见 **[reference/knowledge-type-modes.md](reference/knowledge-type-modes.md)**。`system`/`company` 时 ASD 仍为联邦概要主承载；**不写 DSD/specs YAML 于本库**。

---

## HARD-GATE

草稿总确认前，**禁止**写入 `{DOC_DIR}/requirements/**/ASD-*.md`。

**合法例外**：
- 用户明示跳过门禁或仅要草稿或紧急直写
- 环境变量 `SDX_ARCHITECT_ALLOW_ASD_WRITE=1`

**门禁标记**：会话 spec 使用 `<!-- sdx-architect-gate: PENDING -->`，总确认后为 `<!-- sdx-architect-gate: CONFIRMED -->`，且正文须出现目标 **`ASD-{IDEA-ID}-{N}.md`** basename。

---

## 阶段一：准备

抛出并确认：**IDEA-ID / MVP**、**KNOWLEDGE_TYPE**、`--depth`、门禁 **Ga1（§1）/ Ga2（§2）**。

---

## 阶段二：会话草稿确认

**路径**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-architect.md`。骨架：**[assets/architect-session-spec-template.md](assets/architect-session-spec-template.md)**。

标准 **C/M/S/F** 四选项与同目录 `sdx-design` 的约定一致。

**门禁与 ASD 映射**：

| 门禁 | ASD 章节 |
|------|-----------|
| Ga1 | §1 设计概述 |
| Ga2 | §2 架构设计 |

**brainstorming**：多路径时先做 2～3 套对比；可对照 [../sdx-design/reference/brainstorming-integration.md](../sdx-design/reference/brainstorming-integration.md)。

**总确认**：是否同意以当前草稿为唯一素材生成 **`ASD-{IDEA-ID}-{N}.md`**？确认人：**`$HOME` 末级目录名**。

---

## 阶段三：定稿

在 `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/` 下新建 **`ASD-{IDEA-ID}-{N}.md`**，按 **[assets/asd-template.md](assets/asd-template.md)** 落 **§1、§2** 与文末 YAML。

联邦补充说明：**[assets/asd-stub-sections-federated.md](assets/asd-stub-sections-federated.md)**。

```bash
agent/skills/sdx-architect/scripts/validate-asd.sh
agent/skills/sdx-architect/scripts/validate-asd.sh --file path/to/ASD-xxx.md --gate-check
```

---

## 参考资源

| 资源 | 路径 |
|------|------|
| 联邦 / KNOWLEDGE_TYPE | [reference/knowledge-type-modes.md](reference/knowledge-type-modes.md) |
| 受众与文档语言（可共用） | [../sdx-design/reference/audience-and-language.md](../sdx-design/reference/audience-and-language.md) |
| 设计原则 | [../sdx-design/reference/design-principles.md](../sdx-design/reference/design-principles.md) |
| ASD 模板 | [assets/asd-template.md](assets/asd-template.md) |
| 会话草稿 | [assets/architect-session-spec-template.md](assets/architect-session-spec-template.md) |

---

## 工程化支持

钩子：`python3 agent/hooks/sdx_gate_common.py --gate architect`，注册见 [agent/hooks.json](../../hooks.json)。
