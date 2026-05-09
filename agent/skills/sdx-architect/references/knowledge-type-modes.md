# KNOWLEDGE_TYPE 与 ASD / DSD

**判定**：目标工程 `.docsconfig` 的 **`KNOWLEDGE_TYPE`**（`docs-install --scope=knowledge` 写入；未写入则视为未设置）。`validate-asd.sh` / `validate-dsd.sh` 会读入; **`specs/` 终检**以 DSD（`/sdx-design`）为准。

**章节分工**：ASD（`/sdx-architect`）§1–§3 + §4 附录；DSD（`/sdx-design`）§1–§4，§3 为详设级规约。

## 模式对照

| `KNOWLEDGE_TYPE` | ASD | DSD / 规约 |
|------------------|-----|------------|
| `application` 或未设置 | §1–§3 完整 | 应用库完整 DSD；**spec-asd-*** 在 `{DOC_DIR}/specs/`；**spec-dsd-*** 仅在 `requirements/.../MVP-Phase-*/specs/` |
| `system` / `company` | §1–§3 **联邦概要**（§3 可 `N/A` + 服务能力摘要） | **不在本库落 DSD**；详设与规约在应用库 `/sdx-design`；**不要求**本层建 `specs/` |

## 联邦概要（ASD 内须写清）

系统/公司库只保留粗粒度「引用谁、哪些服务动、动什么」：

1. **§1**：ANALYSIS/PRD/overview 可点击路径。  
2. **§2**：服务变更表为主；下游 DSD 指针见 [asd-stub-sections-federated.md](../assets/asd-stub-sections-federated.md)。  
3. **§3**：与 DSD 同构的摘要表；**不写**契约全文与 specs 终稿。  
4. **不写**应用全量 DSD。

## 与会话门禁（分技能）

- **sdx-architect**：G1–G3 对应 §1–§3（见 `architect-session-spec-template`），可产 **spec-asd-*.md**。  
- **sdx-design**：G1–G4，产 **spec-dsd-*.md**。

联邦场景下 system/company **不写本库 DSD**，无本库 `sdx-design` 门禁；应用知识库再跑 `/sdx-design`。
