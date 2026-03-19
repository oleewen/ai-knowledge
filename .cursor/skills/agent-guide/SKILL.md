---
name: agent-guide
description: >
  生成/更新根目录 README.md（GitHub 惯例）与 AGENTS.md（Agent 契约）。
  以 Index Guide（常见为 INDEX.md）为权威地图按需补读；README 承载命令与文档表，AGENTS 引用之，三文件不重复堆叠。
---

# Agent 指引生成（agent-guide）

面向 **人类开发者（README）** 与 **AI Agent（AGENTS）** 各一份入口文档；**平面检索与路径级精要**留在 **Index Guide**，本 Skill 不负责再造一套「小 INDEX」。

## 1. 何时使用 / 何时不做

| 场景 | 行动 |
|------|------|
| 初始化仓库、onboarding、`/knowledge-build` **第二阶段** | **执行本 Skill** |
| 仅要平面索引、七段 Index Guide | 用 **document-indexing**，不用本 Skill |
| 用户只要改 `system/knowledge/` 实体 | 不强制跑本 Skill；若 AGENTS/README 路径过时再对齐 |

## 2. 输入 / 输出契约

| 类型 | 内容 |
|------|------|
| **输入（可选）** | 用户目标（新建 / 增量更新）、是否必须重做索引、`output` 范围（仅 README / 仅 AGENTS / 两者） |
| **硬输入（探索）** | 优先 **Index Guide 落盘路径**（见 §3）；次选用户粘贴的全文 |
| **输出（固定）** | 仓库根目录 **`README.md`**、**`AGENTS.md`**（路径以项目根为准；单应用工程若有约定根目录则跟约定） |
| **不产出** | 不替代 `INDEX.md` 的 §3 字典；不把 Index 全文合并进 AGENTS |

**上游（建议顺序）**

1. **document-indexing**：提供可导航、可核实的 Index；本 Skill 默认 **信任 Index 已读结论**，§6 盲区不当作事实。
2. **document-change**（若仓库启用变更索引链路）：与增量索引配合时使用；agent-guide **不强制**调用，仅在用户要同步「变更/索引」说明时引用 `changes-index` 路径。

## 3. Index 门控（启动必做）

### 3.1 检测「是否已有 Index Guide」

按优先级查找（命中即停，并记录实际路径写入会话/说明）：

1. 项目根 **`INDEX.md`**、**`INDEX-GUIDE.md`**（标题常含「AI文档库精要索引指南」）
2. **`docs/INDEX.md`**、`docs/INDEX-GUIDE.md`
3. 用户消息/附件中的 Index 全文

### 3.2 用户选择（已有 Index 且用户未声明「必须全量重做索引」）

**须先展示检测结果并等待选择，禁止默认：**

| 选择 | 行为 |
|------|------|
| **重做索引** | 按 `.cursor/skills/document-indexing/SKILL.md` 与用户选定 Mode 更新 Index，再进入 §4 |
| **沿用现有** | 不跑 document-indexing；以当前 Index 为地图进入 §4 |

**若无任何 Index**：优先 **document-indexing ≥ Mode 1** 生成可落盘索引后再探索；用户明确拒绝 Index 时，才用「根配置 + 顶层目录 + 关键 README」做 **降级摸底**，并在 AGENTS 中注明 **地图未标准化、建议补 Index**。

## 4. 探索：以 INDEX 为地图、最小阅读集

**原则**：Index 为 **导航与待办清单**；只打开与「README 首屏 / AGENTS 契约」相关的文件，**禁止**为写 AGENTS 通读全仓。

| Index 节 | 探索用途 | 写入去向（摘要） |
|----------|----------|------------------|
| §1 元信息 | 技术栈、入口、命令 | README：简介 + Quick start；AGENTS：≤3 行 + 指针 |
| §2 拓扑 | 目录边界、依赖方向 | README：**唯一**详写目录树/结构处；AGENTS：短列表 |
| §3 字典 | **按需**打开 ⭐⭐⭐ 与规范相关行 | **不**粘贴进 AGENTS；一句指向 `INDEX.md` |
| §4–§5 | 数据流、配置（若存在） | 仅当 README 要写环境/运行方式时再读 |
| §6 未索引 | 盲区 | 须描述某路径 → **只补读该路径**；否则「详见 INDEX §6」 |
| §7 查阅指北 | 检索顺序 | AGENTS 与此 **一致**，不另写一套矛盾策略 |

**几乎总是要做的轻量校验（可与 Index 对照）**

- **`.ai/CONVENTIONS.md`** 与 **`.ai/rules/`**（目录浏览 + 必要文件头）：规范入口、模板路径须 **真实存在**。
- **已有根 `README.md`**：更新时 **合并重复段落**，保留有效表格/命令块结构。
- **`knowledge/` 或 `system/knowledge/`**：只读各层 **README / INDEX**，不通读实体文档。

## 5. 三文件分工与去重（单一事实源）

| 文件 | 读者 | 放什么 | 不放什么 |
|------|------|--------|----------|
| **INDEX.md** | AI 检索 | 七段、路径精要、未索引声明 | 冗长教程、重复命令百科 |
| **README.md** | 人类、GitHub 首屏 | H1+一句话、Quick start、**文档索引表**、目录结构 | Agent 角色与禁止项长文 |
| **AGENTS.md** | AI | 角色、约束、工作流、禁止项、**短**关键路径 | 完整命令手册（指回 README）、§3 字典副本 |

**去重硬规则**

1. **命令块、选项说明、大链接表** → 只放在 **README**；AGENTS 用「详见 `README.md`」+ 可选 **一条**最常用示例。
2. **项目概述 / 技术栈**（AGENTS）各 **≤3 行**；细节见 README 与 INDEX §1。
3. **查阅顺序**（写进 AGENTS，一句话）：`INDEX.md` → `README.md` → 子域 `**/INDEX.md` 或规范路径。

## 6. 产出：README（GitHub 惯例）与 AGENTS（模板对齐）

### 6.1 建议顺序：**先 README，后 AGENTS**

避免 AGENTS 写满命令后再在 README 重复粘贴；AGENTS 内链指向 README 已定稿的小节。

### 6.2 README.md 推荐骨架

文档型/工具型仓库可删减小节，但 **推荐顺序**保持：

1. **H1 标题 + 单行摘要**
2. **（可选）徽章**
3. **简介**（2–5 句，细节链到 `INDEX.md` 或子文档）
4. **Quick start**（可执行命令；复杂选项链到 `scripts/README.md` 等）
5. **（可选）Features**
6. **Documentation**：用途 | 链接表（人类导航；与 INDEX 互补）
7. **Project structure**：与 Index §2 **一致**，禁止第二套矛盾树
8. **Contributing / License**（按仓库实际）

**合格线**：新读者约 30 秒内知道「是什么、下一步点哪」；相对路径可点、表格不空洞。

### 6.3 AGENTS.md

- **基准**：`.ai/rules/agents-template.md`（可裁剪，**禁止**与模板语义冲突的「先读后改」原则）。
- **建议固定块**：角色与行为 → 与 Index 一致（一句）→ 关键路径（短列表）→ 技术栈（精要）→ 命令（**指针为主**）→ 开发规范 → 工作流 → 禁止事项 → 参考（**首条 `INDEX.md`**，其余链式列举）。
- **事实**：INDEX §6 或未读路径不得写成已核实结论。

## 7. 验收与反模式

**发布前勾选**

- [ ] README 与 AGENTS **无大段重复**
- [ ] AGENTS **未**堆叠 INDEX §3 级字典
- [ ] README 文档表、AGENTS「参考」、INDEX 内路径 **一致、可跳转**
- [ ] 命令在 README 中 **可复制执行**（或明确链到含命令的子文档）
- [ ] 规范/模板路径在磁盘上 **存在**

**反模式（禁止）**

- 在 AGENTS 里重写一份「完整文档索引表」
- 无 Index 时编造目录/模块细节
- README 与 INDEX §2 目录树 **互相矛盾**
- 把「未索引」区域写死为已读事实

## 8. 与其他 Skill 的衔接

| Skill | 关系 |
|-------|------|
| **document-indexing** | 本 Skill **依赖其产出**作为探索主地图；门控见 §3 |
| **knowledge-build** | 其 **第二阶段** 即本 Skill；完成后第三阶段才写 `knowledge/` |
| **knowledge-upgrade** | 通常 **不含**本阶段；应用内若有独立 AGENTS/README 约定则跟应用 INDEX |

## 9. 参考路径

- Index 结构与模式：`.cursor/skills/document-indexing/SKILL.md`
- Agent 文档模板：`.ai/rules/agents-template.md`
- 规范索引：`.ai/CONVENTIONS.md`、`.ai/rules/`
