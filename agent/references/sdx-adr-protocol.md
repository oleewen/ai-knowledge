# SDX ↔ ADR 协议

> **定位**：`sdx-solution` / `sdx-analysis` 运行时如何落技术决策到 `{DOC_DIR}/adr/`。  
> **结构/命名 SSOT**：仍见 [adr-guidelines.md](../knowledge/adr-guidelines.md)、[adr-template.md](../knowledge/adr-template.md)。  
> **不负责**：业务/范围/优先级决策（仍用 SOLUTION §5.2 Q-n 等）。

**最后更新**: 2026-07-29

---

## 边界

| 决策类型 | 落点 |
| --- | --- |
| 业务 / 范围 / 优先级 / 里程碑取舍 | SOLUTION §5.2 **Q-n**（ANALYSIS 无 Q-n 表） |
| **技术 / 架构选型**（有持久后果） | `{DOC_DIR}/adr/ADR-*.md` + 登记 `CONTEXT.md` |

技术决策**不写入** Q-n 表行。

---

## 落盘位置

| 层 | 目录 | 索引 |
| --- | --- | --- |
| 应用 | `application/adr/` | `CONTEXT.md`（决策台账）+ `index.md`（导航） |
| 系统 | `system/adr/` | 同上 |
| 公司 | `company/adr/` | 同上 |

按 `.docsconfig` 的 `KNOWLEDGE_TYPE` / `DOC_DIR` 与决策范围选层。技能**只维护** `CONTEXT.md` 与 `ADR-*.md`；`index.md` 仅导航。

---

## CONTEXT.md 列

| 列 | 定义 |
| --- | --- |
| 分类 | **优先按模块**（有 `PM-*` 等用 ID；否则方案内模块/能力短名） |
| 决策编号 | `ADR-{序号}`（与文件名序号一致） |
| 决策要点 | 一行结论 |
| SSOT | 主要业务文档路径（发起/主引的 `SOLUTION-*.md` 或 `ANALYSIS-*.md`） |
| ADR锚点 | 相对链接到 `ADR-*.md` |

---

## 正文引用

| 产物 | 位置 |
| --- | --- |
| `SOLUTION-*.md` | §5.2 问题决策表**之后**一行，链 `{DOC_DIR}/adr/CONTEXT.md` |
| `ANALYSIS-*.md` | **§6.2 参考文档** 列入 CONTEXT / 相关 ADR（不单开 §5.3） |

---

## 时机与门禁

1. 烤干收敛后、用户选推进（**C**）前：正文可暂留 `ADR-待定` 类占位。
2. **推进门禁**：本段涉及的新技术决策须已落 `ADR-*.md`、已登记 `CONTEXT.md`，且正文已链 CONTEXT（或具体 ADR）；占位须清除。
3. 新 ADR 初始状态：**已通过 (Accepted)**。

---

## 写前检索与冲突

1. 写前必查本层 `CONTEXT.md`（及既有 `ADR-*.md`）。
2. **结论一致** → 复用，只补引用。
3. **冲突** → 停问用户：复用旧结论 / 修订旧 ADR / 新建并 `Superseded` 关系。禁止静默平行两份同主题 Accepted。

---

## ANALYSIS 新增 ADR

| 情况 | 做法 |
| --- | --- |
| 实现向、**不改**业务边界 / 集成边界 | 允许在本层新建 ADR + CONTEXT；§6.2 补链 |
| 改变范围、系统边界、跨系统集成方式 | **禁止**仅在 ANALYSIS 落盘；硬停回 `/sdx-solution` |

---

## 校验（轻量）

出现 `ADR-*` / `ADR-待定` 时：`validate-solution.sh` / `validate-analysis.sh` 检查 CONTEXT 链、对应文件存在、CONTEXT 有登记行；残留占位给警告。无 ADR 引用时不强制空链。

---

## 技能挂接

- [sdx-solution/workflow.md](../skills/sdx-solution/references/workflow.md) · [gates.md](../skills/sdx-solution/references/gates.md)
- [sdx-analysis/workflow.md](../skills/sdx-analysis/references/workflow.md) · [gates.md](../skills/sdx-analysis/references/gates.md)
