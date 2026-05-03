# 系统知识库设计（精简版）

本文件定义 `system/` 的设计边界、目录契约、映射闭环与演进策略。  
`system/` 负责系统知识库的治理编排；应用级实体事实源仍以 `application/` 为准。

---

## 阅读顺序

1. [README.md](README.md) — 系统知识库定位与目录说明
2. 本文 — 设计边界、映射与治理流程
3. [constitution/README.md](constitution/README.md) — 治理层职责
4. [architecture/README.md](architecture/README.md) — 架构聚合视图入口
5. [../application/DESIGN.md](../application/DESIGN.md) — 应用侧 SSOT 设计依据

---

## 1. 定位与边界

`system/DESIGN.md` 的定位是系统知识库的设计说明，核心职责是定义 `system/` 的治理结构、联邦槽位与上下行同步机制。

- `application/` 是应用级实体与关系字段的 SSOT；
- `system/` 是系统级索引治理层，承载聚合视图、镜像槽位与归档编排；
- `system/` 可引用 `application/`，但不复制其字段级规范。

边界约束：

- **结构边界**：`constitution/`、`architecture/`、`application-{name}/` 职责分离；
- **流程边界**：通过 `docs-pull` 与 `docs-distill` 形成同步闭环；
- **事实边界**：`system` 维护治理事实，`application` 维护实体主定义。

---

## 2. 元模型与目录契约

`system/` 采用“治理层 -> 架构层 -> 联邦层”三层模型，聚焦治理编排，不承担应用实体主数据定义。

| 层级 | 目录 | 职责 |
| --- | --- | --- |
| 治理层 | `constitution/` | 定义术语边界、槽位规则、职责划分与引用规范 |
| 架构层 | `architecture/` | 提供业务/产品/系统/数据架构的系统级聚合视图 |
| 联邦层 | `application-{name}/` | 应用镜像挂载槽位，承接拉取内容并支持归档追溯 |

目录契约：

- `system/` 维护目录语义、映射关系与流程约束；
- `application` 侧字段规则仅作为引用，不在 `system` 重复定义；
- 目录扩展优先更新契约，再落地内容。

---

## 3. system 与 application 映射与同步闭环

两者关系定义为“**索引治理层 ↔ 实体事实层**”。

- **事实来源**：业务/产品/技术/数据实体及字段语义以 `application/` 为准；
- **治理映射**：`system/` 通过 `architecture/` 与 `application-{name}/` 维护跨应用可读视图与镜像挂载关系；
- **引用方式**：优先路径引用与 ID 引用，避免在 `system` 冗余复制实体正文。

同步闭环：

1. **下行拉取（docs-pull）**：同步目标应用文档至 `system/application-{name}/`；
2. **治理校核（system 层）**：在 `constitution/` 与 `architecture/` 执行一致性检查；
3. **上行蒸馏（docs-distill）**：将已核实内容归并到系统主库结构；
4. **追溯记录（changelogs）**：保留索引与变更日志用于审计和回放。

---

## 4. 质量门禁与演进策略

质量门禁采用“轻规范、强可追溯”：

- **一致性门禁**：术语、目录职责与引用路径应与 `README.md`、`AGENTS.md`、`INDEX_GUIDE.md` 对齐；
- **边界门禁**：`system` 文档不引入 `application` 字段级实体定义；
- **同步门禁**：涉及 `application-{name}/` 更新须记录来源、影响范围与回写策略；
- **演进门禁**：新增目录或流程，先更新本文件契约，再更新实现文档。

演进顺序：

1. 稳定三层模型（治理/架构/联邦槽位）；
2. 增补模板与自动化检查（术语巡检、引用完整性检查）；
3. 仅在 `system` 出现独立事实源时，再引入字段级细化规则。

---

## 参考

- [README.md](README.md)
- [INDEX_GUIDE.md](INDEX_GUIDE.md)
- [constitution/README.md](constitution/README.md)
- [architecture/README.md](architecture/README.md)
- [../application/DESIGN.md](../application/DESIGN.md)
