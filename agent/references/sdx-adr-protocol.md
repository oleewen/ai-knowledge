# SDX ↔ ADR 协议

> **定位**：`sdx-analysis` / `sdx-feature` 运行时如何落技术决策到 `{DOC_DIR}/adr/`。  
> **产物规范**：命名、目录、章节、状态与 CONTEXT 列见 [adr-guidelines.md](../knowledge/adr-guidelines.md)；内容骨架见 [adr-template.md](../knowledge/adr-template.md)。
> **不负责**：业务/范围/优先级决策（仍用 ANALYSIS 或 SOLUTION §5.2 Q-n）。
> **技能挂接**：[sdx-analysis](../skills/sdx-analysis/references/workflow.md) · [gates](../skills/sdx-analysis/references/gates.md)；[sdx-feature](../skills/sdx-feature/references/workflow.md) · [gates](../skills/sdx-feature/references/gates.md)。

**最后更新**: 2026-10-23

---

## 边界

| 决策类型 | 落点 |
| --- | --- |
| 业务 / 范围 / 优先级 / 里程碑取舍 | ANALYSIS 或 SOLUTION §5.2 **Q-n** |
| **技术 / 架构选型**（有持久后果） | `{DOC_DIR}/adr/ADR-*.md` + 登记 `CONTEXT.md` |

技术决策**不写入** Q-n 表行。

---

## 落盘与引用

按 `.docsconfig` 的 `KNOWLEDGE_TYPE` / `DOC_DIR` 与决策范围选层，目录和 CONTEXT 五列以 [ADR产物规范](../knowledge/adr-guidelines.md) 为准。技能只维护 `CONTEXT.md` 与 `ADR-*.md`；`index.md` 仅导航。

**正文引用**

| 产物 | 位置 |
| --- | --- |
| `SOLUTION-*.md` | §5.2 问题决策表**之后**一行，链 `{DOC_DIR}/adr/CONTEXT.md` |
| `ANALYSIS-*.md` | §5.2 问题决策表后链接 CONTEXT；§7.2 可汇总相关引用 |
| `FEATURE-*.md` | §6.2 参考文档列入 CONTEXT / 相关 ADR |

---

## 门禁与冲突

1. 烤干收敛后、用户选推进（**C**）前：正文可暂留 `ADR-待定` 类占位。  
2. **推进门禁**：本段涉及的新技术决策须已落 `ADR-*.md`、已登记 `CONTEXT.md`，且正文已链 CONTEXT（或具体 ADR）；占位须清除。  
3. 新 ADR 初始状态：**已通过 (Accepted)**。  
4. 写前必查本层 `CONTEXT.md`（及既有 `ADR-*.md`）。  
5. **结论一致** → 复用，只补引用。  
6. **冲突** → 停问用户：复用旧结论 / 修订旧 ADR / 新建并 `Superseded` 关系。禁止静默平行两份同主题 Accepted。

**校验（轻量）**：出现 `ADR-*` / `ADR-待定` 时，`validate-analysis.sh` / `validate-feature.sh` 检查 CONTEXT 链、对应文件存在、CONTEXT 有登记行；残留占位给警告。无 ADR 引用时不强制空链。

---

## 约束

| 情况 | 做法 |
| --- | --- |
| 实现向、**不改**业务边界 / 集成边界 | 允许在本层新建 ADR + CONTEXT；按上表对应产物补链 |
| 改变范围、系统边界、跨系统集成方式 | **禁止**仅在 FEATURE 落盘；硬停回 `/sdx-analysis`（改七章 ANALYSIS） |
