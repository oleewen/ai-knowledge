# 知识库类型与 ASD / DSD（sdx-architect + sdx-design）

> 判定依据：目标工程根 `.docsconfig` 中的 **`KNOWLEDGE_TYPE`**（由 `docs-install --scope=knowledge` 写入；`scope=config` 可能未写，此时视为**未设置**）。  
> `validate-asd.sh`、`validate-dsd.sh` 会读入该键；**`specs/` 终检规则**以 **DSD**（`/sdx-design`）侧为准。

拆分后：

- **ASD**（`/sdx-architect`）：§1 设计概述、§2 架构设计。  
- **DSD**（`/sdx-design`）：§1 设计概述（与 ASD §1 / `asd-template` 对齐）、§2 详细设计、§3 需求规约、§4 附录；应用全量场景下 **`specs/**/*.yaml`** 与 DSD 同步落盘。

---

## 模式对照

| `KNOWLEDGE_TYPE` | ASD（架构） | DSD（详细设计 + 规约） | `specs/**/*.yaml` |
|------------------|------------|------------------------|-------------------|
| `application` 或（未设置） | §1–§2 完整 | §1–§4 完整（**§1** 溯源 ASD；详设 **§2** 起） | **需要**（按 `sdx-design` 阶段三落盘） |
| `system` / `company` | §1–§2 **联邦概要**（边界、服务变更、引用链） | **不在本库落 DSD**；由**应用知识库**按需补 **DSD**，本层无 `specs/` | **不要求**（可不建 `specs/`） |

---

## 联邦概要：必须写清什么（ASD 内）

在 **系统库 / 公司库**仅保留粗粒度「引用谁、哪些服务动、动什么」：

1. **引用与范围**（§1）：ANALYSIS / PRD / 相关 overview 的可点击路径。  
2. **服务与变更**（§2）：服务变更表为核心；下游 DSD 指针见 [asd-stub-sections-federated.md](../assets/asd-stub-sections-federated.md)。  
3. **不写**应用全量 DSD 与 `specs/`；详设与规约在应用库 **DSD** 收口。

---

## 与会话门禁（分别技能）

- **sdx-architect**：门禁对应 **Ga1→§1、Ga2→§2**（会话 spec 见 architect-session-spec-template）。  
- **sdx-design**：门禁对应 **Gd1→§1 … Gd4→§4**，**应用全量**时含规约 YAML 草案与终盘。

联邦场景下 **不写 DSD 于 system/company**，故无 `sdx-design` 门禁激活于本库；转至应用知识库后再跑 `/sdx-design`。
