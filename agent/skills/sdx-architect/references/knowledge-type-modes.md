# KNOWLEDGE_TYPE 与 ASD / DSD

**来源**：`.docsconfig` 的 `KNOWLEDGE_TYPE`（`docs-install --scope=knowledge`；未设置即未声明）。`validate-asd.sh` / `validate-dsd.sh` 会读入。应用库 **详设正文**由 **DSD**（`/sdx-design`，§1–§3）承载。

**布局契约**（路径、overview、SDD 落盘）：[knowledge-layout.md](../../../references/knowledge-layout.md)。

**分工**：ASD（`/sdx-architect`）§1–§3 + §4 附录；DSD（`/sdx-design`）§1–§3，**§2** 为实现级契约主体。

## 模式

| `KNOWLEDGE_TYPE` | ASD | DSD / 落地 |
|------------------|-----|------------|
| `application` 或未设置 | §1–§3 完整 | 应用库 **DSD-*.md**；**spec-asd-*** → `{DOC_DIR}/specs/` |
| `system` / `company` | §1–§3 联邦概要（§3 可 `N/A` + 能力摘要） | 本库不落 DSD；详设 → 应用库 `/sdx-design`；本层不要求应用级 Phase 拆分目录 |

## 联邦概要要点

粗粒度回答：引用对象、涉及服务、变更方向。

**架构输入**（先读再写）：

| 模式 | 五视角入口 |
| --- | --- |
| `system` | [system/architecture/README.md](../../../../system/architecture/README.md)；overview 摘要见 `system/architecture/overview/` |
| `company` | [company/ea/README.md](../../../../company/ea/README.md)；overview 摘要见 `company/ea/overview/` |

1. **§1**：ANALYSIS/PRD/overview 链接  
2. **§2**：服务变更表；下游指针见 [asd-stub-sections-federated.md](../assets/asd-stub-sections-federated.md)  
3. **§3**：摘要表；无契约终稿正文  
4. 无应用全量 DSD

## 门禁（分技能）

- **sdx-architect**：G1–G3 ↔ §1–§3（`architect-session-spec-template`）；可产 **spec-asd-*.md**  
- **sdx-design**：G1–G3 ↔ DSD §1–§3

system/company：本库无 DSD 门禁；详设在应用库跑 `/sdx-design`。
