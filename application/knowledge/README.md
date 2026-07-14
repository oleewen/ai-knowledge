---
type: Documentation
title: knowledge（应用侧知识主体）
---
# knowledge（应用侧知识主体）

索引入口见 [index.md](index.md)。

**应用侧知识树**（联邦单元内 `knowledge/`）：承接 **业务 / 产品 / 应用 / 数据 / 技术** 五视角的实体登记、实现映射与应用层实体主定义；治理与命名 SSOT 见 [`../../agent/knowledge/knowledge-governance.md`](../../agent/knowledge/knowledge-governance.md)。与中央库 `application/knowledge/` 同构。中央库阶段文档（solutions、analysis）见 [`../solutions`](../solutions/README.md)、[`../analysis`](../analysis/README.md)；本应用 requirements 以本树及中央库为事实源；归档时可回写。

---

## 五视角实体 ID 与登记

- **链上实体 ID 登记表**：[index.md](index.md) — business / product / application / data / technical 五视角（**不含** `DIR-*` 联邦/阶段）。`application/` 入口见 [../README.md](../README.md)；仓库根 Index Guide 见 [index.md](../../index.md) **§1.2**。
- **视角实例索引**：各视角实体文件 `{ID}.md`（OKF 概念实体 SSOT）；ID 登记表 [index.md](index.md)（扫描生成）。
- **机器契约**：[../../agent/skills/docs-build/SKILL.md](../../agent/skills/docs-build/SKILL.md)（ssot、symmetry、meta_read_order）；[knowledge-meta.md](knowledge-meta.md) 保留联邦/目录元数据。

## 维护（三步）

1. 改前读 **机器契约**（见上）、本目录 [knowledge-meta.md](knowledge-meta.md)（目录元数据）与目标视角 `README.md`、相关 `{perspective}-meta.md`
2. 只增删改 **ID** 与 Markdown 约定字段；跨视角不写重复叙述
3. 更新 [index.md](index.md)（各视角实体 ID）或该视角 README 中的登记 / 示例（若影响导航）

**索引指针**：各视角实体 ID [index.md](index.md)；仓库根 [index.md](../../index.md)；`application/` 九章索引与中央知识库挂载建联登记 [../index.md](../index.md)。

---

## 约定（最小集）

- 文内路径优先可解析的相对路径（如自 `knowledge/` 起）
- PL/PM/FT、SYS、DS/ENT、MW/CMP 等元数据 **集中在各视角根目录**，细则见各 `README.md` 与 DESIGN §2
