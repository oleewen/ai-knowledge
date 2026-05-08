# 知识库类型与 ASD / DSD（sdx-architect + sdx-design）

> 判定依据：目标工程根 `.docsconfig` 中的 **`KNOWLEDGE_TYPE`**（由 `docs-install --scope=knowledge` 写入；`scope=config` 可能未写，此时视为**未设置**）。  
> `validate-asd.sh`、`validate-dsd.sh` 会读入该键；**`specs/` 终检规则**以 **DSD**（`/sdx-design`）侧为准。

拆分后：

- **ASD**（`/sdx-architect`）：§1 设计概述、§2 架构设计、§3 需求规约（概要级摘要表，与 ASD §3 需求规约表头对齐）、§4 附录。  
- **DSD**（`/sdx-design`）：§1 设计概述、§2 详细设计、§3 需求规约（详设级需求规约，与 DSD §3 需求规约表头对齐）、§4 附录。

---

## 模式对照

| `KNOWLEDGE_TYPE` | ASD（架构） | DSD（详细设计 + 规约） | `spec-asd-*.md` / `spec-dsd-*.md`（`{DOC_DIR}/specs/`） |
|------------------|------------|------------------------|-------------------|
| `application` 或（未设置） | §1–§3 完整 | §1–§4 完整（**§1** 溯源 ASD；**§3** 溯源并扩写 **ASD §3**；详设 **§2** 起） | **需要**：架构草案 **spec-asd-***（`/sdx-architect`）、详设终稿 **spec-dsd-***（`/sdx-design`，按阶段落盘） |
| `system` / `company` | §1–§3 **联邦概要**（§3 可为 `N/A` 路径 + 服务能力摘要） | **不在本库落 DSD**；由**应用知识库**按需补 **DSD**，本层无 `specs/` | **不要求**（可不建 `specs/`） |

---

## 联邦概要：必须写清什么（ASD 内）

在 **系统库 / 公司库**仅保留粗粒度「引用谁、哪些服务动、动什么」：

1. **引用与范围**（§1）：ANALYSIS / PRD / 相关 overview 的可点击路径。  
2. **服务与变更**（§2）：服务变更表为核心；下游 DSD 指针见 [asd-stub-sections-federated.md](../assets/asd-stub-sections-federated.md)。  
3. **需求规约摘要**（§3）：与 DSD 同构三列表；**不写**契约全文与 **`specs/`** 终稿。  
4. **不写**应用全量 **DSD**；详设与规约落盘在应用库 **DSD** 收口。

---

## 与会话门禁（分别技能）

- **sdx-architect**：门禁对应 **G1→§1、G2→§2、G3→§3**（会话 spec 见 architect-session-spec-template），产出 **`spec-asd-*.md`**（概要规约）。  
- **sdx-design**：门禁对应 **G1→§1 … G4→§4**，产出 **`spec-dsd-*.md`** 详设规约。

联邦场景下 **不写 DSD 于 system/company**，故无 `sdx-design` 门禁激活于本库；转至应用知识库后再跑 `/sdx-design`。
